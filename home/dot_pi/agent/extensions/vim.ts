import {
  CustomEditor,
  type ExtensionAPI,
} from "@earendil-works/pi-coding-agent";
import {
  matchesKey,
  truncateToWidth,
  visibleWidth,
} from "@earendil-works/pi-tui";

type Mode = "normal" | "insert";
type Pos = { line: number; col: number };
type Snapshot = { text: string; cursor: Pos };
type Register = { text: string; linewise: boolean };
type Target = { pos: Pos; linewise: boolean; inclusive: boolean };
type Parse<T> = T | "pending" | null;

// The editor exposes no public cursor setter, so position is driven by
// replaying the movement keys it already binds.
const KEY = {
  up: "\x1b[A",
  down: "\x1b[B",
  right: "\x1b[C",
  left: "\x1b[D",
  lineStart: "\x01",
  lineEnd: "\x05",
} as const;

const isDigit = (c: string) => c >= "0" && c <= "9";

function charClass(c: string): "word" | "punct" | "space" {
  if (/\s/.test(c)) return "space";
  if (/[A-Za-z0-9_]/.test(c)) return "word";
  return "punct";
}

function toOffset(lines: string[], p: Pos): number {
  let off = 0;
  for (let i = 0; i < p.line; i++) off += (lines[i]?.length ?? 0) + 1;
  return off + p.col;
}

function toPos(lines: string[], off: number): Pos {
  let rest = Math.max(0, off);
  for (let i = 0; i < lines.length; i++) {
    const len = lines[i]?.length ?? 0;
    if (rest <= len) return { line: i, col: rest };
    rest -= len + 1;
  }
  const last = Math.max(0, lines.length - 1);
  return { line: last, col: lines[last]?.length ?? 0 };
}

function firstNonBlank(line: string): number {
  const i = line.search(/\S/);
  return i === -1 ? 0 : i;
}

function wordForward(text: string, off: number, count: number): number {
  let i = off;
  for (let n = 0; n < count; n++) {
    if (i >= text.length) break;
    const cls = charClass(text[i]!);
    if (cls !== "space")
      while (i < text.length && charClass(text[i]!) === cls) i++;
    while (i < text.length && charClass(text[i]!) === "space") i++;
  }
  return i;
}

function wordBackward(text: string, off: number, count: number): number {
  let i = off;
  for (let n = 0; n < count; n++) {
    i--;
    while (i >= 0 && charClass(text[i]!) === "space") i--;
    if (i < 0) break;
    const cls = charClass(text[i]!);
    while (i > 0 && charClass(text[i - 1]!) === cls) i--;
  }
  return Math.max(0, i);
}

function wordEnd(text: string, off: number, count: number): number {
  let i = off;
  for (let n = 0; n < count; n++) {
    i++;
    while (i < text.length && charClass(text[i]!) === "space") i++;
    if (i >= text.length) break;
    const cls = charClass(text[i]!);
    while (i + 1 < text.length && charClass(text[i + 1]!) === cls) i++;
  }
  return Math.min(i, Math.max(0, text.length - 1));
}

class VimEditor extends CustomEditor {
  private mode: Mode = "insert";
  private pending = "";
  private register: Register = { text: "", linewise: false };
  private undos: Snapshot[] = [];
  private redos: Snapshot[] = [];
  private insertAnchor?: Snapshot;
  private lastChange?: string;
  private enteredInsert = false;
  private replaying = false;

  // --- state plumbing ---

  private snapshot(): Snapshot {
    return { text: this.getText(), cursor: this.getCursor() };
  }

  private clamp(lines: string[], p: Pos): Pos {
    const line = Math.max(0, Math.min(p.line, Math.max(0, lines.length - 1)));
    const len = lines[line]?.length ?? 0;
    const max = this.mode === "normal" ? Math.max(0, len - 1) : len;
    return { line, col: Math.max(0, Math.min(p.col, max)) };
  }

  private restoreCursor(target: Pos): void {
    const lines = this.getLines();
    const t = this.clamp(lines, target);
    // Vertical keys step one *visual* line, so loop on the logical index.
    // Never runs at the first/last visual line, so history browsing can't trigger.
    let guard = 0;
    while (this.getCursor().line !== t.line && guard++ < 10000) {
      super.handleInput(this.getCursor().line > t.line ? KEY.up : KEY.down);
    }
    const len = lines[t.line]?.length ?? 0;
    if (t.col <= len - t.col) {
      super.handleInput(KEY.lineStart);
      for (let n = 0; n < t.col; n++) super.handleInput(KEY.right);
    } else {
      super.handleInput(KEY.lineEnd);
      for (let n = 0; n < len - t.col; n++) super.handleInput(KEY.left);
    }
  }

  private apply(text: string, cursor: Pos, recordUndo = true): void {
    if (recordUndo && text !== this.getText()) {
      this.undos.push(this.snapshot());
      this.redos.length = 0;
    }
    // setText() clears the paste map, so skip it for pure motions.
    if (text !== this.getText()) this.setText(text);
    this.restoreCursor(cursor);
    this.invalidate();
    this.tui.requestRender();
  }

  private moveTo(pos: Pos): void {
    this.restoreCursor(pos);
    this.invalidate();
    this.tui.requestRender();
  }

  private setMode(mode: Mode): void {
    if (mode === this.mode) return;
    if (mode === "insert") {
      this.insertAnchor = this.snapshot();
      this.enteredInsert = true;
    } else if (this.insertAnchor) {
      // A whole insert session collapses into one undo step, as in vim.
      if (this.insertAnchor.text !== this.getText()) {
        this.undos.push(this.insertAnchor);
        this.redos.length = 0;
      }
      this.insertAnchor = undefined;
    }
    this.mode = mode;
  }

  // --- motions ---

  private motion(seq: string, count: number): Parse<Target> {
    const lines = this.getLines();
    const cur = this.getCursor();
    const text = this.getText();
    const off = toOffset(lines, cur);
    const line = lines[cur.line] ?? "";
    const char = (pos: Pos, inclusive = false): Target => ({
      pos,
      linewise: false,
      inclusive,
    });
    const vert = (pos: Pos): Target => ({
      pos,
      linewise: true,
      inclusive: false,
    });

    switch (seq) {
      case "h":
        return char({ line: cur.line, col: Math.max(0, cur.col - count) });
      case "l":
        return char({
          line: cur.line,
          col: Math.min(line.length, cur.col + count),
        });
      case "j":
        return vert({
          line: Math.min(lines.length - 1, cur.line + count),
          col: cur.col,
        });
      case "k":
        return vert({ line: Math.max(0, cur.line - count), col: cur.col });
      case "0":
        return char({ line: cur.line, col: 0 });
      case "^":
        return char({ line: cur.line, col: firstNonBlank(line) });
      case "$":
        return char(
          { line: cur.line, col: Math.max(0, line.length - 1) },
          true,
        );
      case "w":
        return char(toPos(lines, wordForward(text, off, count)));
      case "b":
        return char(toPos(lines, wordBackward(text, off, count)));
      case "e":
        return char(toPos(lines, wordEnd(text, off, count)), true);
      case "G":
        return vert({ line: lines.length - 1, col: 0 });
      case "gg":
        return vert({ line: 0, col: 0 });
      case "g":
        return "pending";
      default:
        return null;
    }
  }

  // --- operators ---

  private operate(op: "d" | "c" | "y", target: Target): void {
    const lines = this.getLines();
    const cur = this.getCursor();

    if (target.linewise) {
      const a = Math.min(cur.line, target.pos.line);
      const b = Math.max(cur.line, target.pos.line);
      const taken = lines.slice(a, b + 1).join("\n");
      this.register = { text: taken, linewise: true };
      if (op === "y") return this.moveTo({ line: a, col: cur.col });
      const rest = [...lines.slice(0, a), ...lines.slice(b + 1)];
      if (op === "c") {
        rest.splice(a, 0, "");
        this.setMode("insert");
        return this.apply(rest.join("\n"), { line: a, col: 0 });
      }
      const next = rest.length > 0 ? rest : [""];
      const landing = Math.min(a, next.length - 1);
      return this.apply(next.join("\n"), {
        line: landing,
        col: firstNonBlank(next[landing] ?? ""),
      });
    }

    const text = this.getText();
    const from = toOffset(lines, cur);
    const to = toOffset(lines, target.pos) + (target.inclusive ? 1 : 0);
    const [a, b] = from <= to ? [from, to] : [to, from];
    this.register = { text: text.slice(a, b), linewise: false };
    if (op === "y") return this.moveTo(toPos(lines, a));
    const next = text.slice(0, a) + text.slice(b);
    if (op === "c") this.setMode("insert");
    this.apply(next, toPos(next.split("\n"), a));
  }

  private paste(after: boolean, count: number): void {
    if (!this.register.text) return;
    const lines = this.getLines();
    const cur = this.getCursor();

    if (this.register.linewise) {
      const block: string[] = [];
      for (let n = 0; n < count; n++)
        block.push(...this.register.text.split("\n"));
      const at = after ? cur.line + 1 : cur.line;
      const next = [...lines.slice(0, at), ...block, ...lines.slice(at)];
      return this.apply(next.join("\n"), {
        line: at,
        col: firstNonBlank(next[at] ?? ""),
      });
    }

    const text = this.getText();
    const line = lines[cur.line] ?? "";
    const at = toOffset(lines, cur) + (after && line.length > 0 ? 1 : 0);
    const chunk = this.register.text.repeat(count);
    const next = text.slice(0, at) + chunk + text.slice(at);
    this.apply(next, toPos(next.split("\n"), at + chunk.length - 1));
  }

  private undoOne(): void {
    const prev = this.undos.pop();
    if (!prev) return;
    this.redos.push(this.snapshot());
    this.apply(prev.text, prev.cursor, false);
  }

  private redoOne(): void {
    const next = this.redos.pop();
    if (!next) return;
    this.undos.push(this.snapshot());
    this.apply(next.text, next.cursor, false);
  }

  // --- normal-mode grammar: [count] (command | operator [count] (motion | doubled)) ---

  private exec(seq: string): "done" | "pending" | "invalid" {
    let i = 0;
    const readCount = (): number => {
      let s = "";
      while (
        i < seq.length &&
        isDigit(seq[i]!) &&
        !(s === "" && seq[i] === "0")
      )
        s += seq[i++];
      return s === "" ? 0 : Number.parseInt(s, 10);
    };

    const n1 = readCount();
    if (i >= seq.length) return "pending";
    const key = seq[i]!;

    if (key === "d" || key === "c" || key === "y") {
      i++;
      const n2 = readCount();
      if (i >= seq.length) return "pending";
      const count = (n1 || 1) * (n2 || 1);
      const rest = seq.slice(i);
      if (rest === key) {
        const cur = this.getCursor();
        this.operate(key, {
          pos: { line: cur.line + count - 1, col: 0 },
          linewise: true,
          inclusive: false,
        });
        return "done";
      }
      const target = this.motion(rest, count);
      if (target === "pending") return "pending";
      if (!target) return "invalid";
      this.operate(key, target);
      return "done";
    }

    const count = n1 || 1;
    const rest = seq.slice(i);
    const lines = this.getLines();
    const cur = this.getCursor();
    const line = lines[cur.line] ?? "";
    const text = this.getText();

    switch (rest) {
      case "i":
        this.setMode("insert");
        return "done";
      case "a":
        this.setMode("insert");
        this.moveTo({
          line: cur.line,
          col: Math.min(line.length, cur.col + 1),
        });
        return "done";
      case "I":
        this.setMode("insert");
        this.moveTo({ line: cur.line, col: firstNonBlank(line) });
        return "done";
      case "A":
        this.setMode("insert");
        this.moveTo({ line: cur.line, col: line.length });
        return "done";
      case "o": {
        const next = [...lines];
        next.splice(cur.line + 1, 0, "");
        this.setMode("insert");
        this.apply(next.join("\n"), { line: cur.line + 1, col: 0 });
        return "done";
      }
      case "O": {
        const next = [...lines];
        next.splice(cur.line, 0, "");
        this.setMode("insert");
        this.apply(next.join("\n"), { line: cur.line, col: 0 });
        return "done";
      }
      case "x": {
        if (line.length === 0) return "done";
        const off = toOffset(lines, cur);
        const end = Math.min(off + count, off + (line.length - cur.col));
        this.register = { text: text.slice(off, end), linewise: false };
        const next = text.slice(0, off) + text.slice(end);
        this.apply(next, toPos(next.split("\n"), off));
        return "done";
      }
      case "X": {
        if (cur.col === 0) return "done";
        const off = toOffset(lines, cur);
        const start = off - Math.min(count, cur.col);
        this.register = { text: text.slice(start, off), linewise: false };
        const next = text.slice(0, start) + text.slice(off);
        this.apply(next, toPos(next.split("\n"), start));
        return "done";
      }
      case "D":
      case "C": {
        this.operate(rest === "D" ? "d" : "c", {
          pos: { line: cur.line, col: Math.max(0, line.length - 1) },
          linewise: false,
          inclusive: true,
        });
        return "done";
      }
      case "s": {
        this.operate("c", {
          pos: {
            line: cur.line,
            col: Math.min(line.length - 1, cur.col + count - 1),
          },
          linewise: false,
          inclusive: true,
        });
        return "done";
      }
      case "S":
        this.operate("c", {
          pos: { line: cur.line + count - 1, col: 0 },
          linewise: true,
          inclusive: false,
        });
        return "done";
      case "p":
        this.paste(true, count);
        return "done";
      case "P":
        this.paste(false, count);
        return "done";
      case "u":
        for (let n = 0; n < count; n++) this.undoOne();
        return "done";
      case "\x12": // ctrl+r
        for (let n = 0; n < count; n++) this.redoOne();
        return "done";
      case ".": {
        if (!this.lastChange || this.replaying) return "done";
        this.replaying = true;
        try {
          this.exec(this.lastChange);
        } finally {
          this.replaying = false;
        }
        return "done";
      }
    }

    const target = this.motion(rest, count);
    if (target === "pending") return "pending";
    if (!target) return "invalid";
    this.moveTo(target.pos);
    return "done";
  }

  // --- input ---

  override handleInput(data: string): void {
    if (this.isShowingAutocomplete()) {
      super.handleInput(data);
      return;
    }

    if (matchesKey(data, "escape")) {
      if (this.mode === "insert") {
        this.setMode("normal");
        const cur = this.getCursor();
        this.moveTo({ line: cur.line, col: Math.max(0, cur.col - 1) });
        return;
      }
      this.pending = "";
      super.handleInput(data); // normal mode: let escape abort the agent
      return;
    }

    if (this.mode === "insert") {
      super.handleInput(data);
      return;
    }

    const seq = this.pending + data;
    const changesText = this.getText();
    this.enteredInsert = false;
    const result = this.exec(seq);

    if (result === "pending") {
      this.pending = seq;
      this.tui.requestRender();
      return;
    }
    this.pending = "";

    if (
      result === "done" &&
      !this.enteredInsert &&
      this.getText() !== changesText &&
      seq !== "."
    ) {
      this.lastChange = seq;
    }
    if (result === "invalid") {
      // Swallow stray printables; forward control keys (ctrl+c, ctrl+d, history).
      if (!(data.length === 1 && data.charCodeAt(0) >= 32))
        super.handleInput(data);
    }
    this.tui.requestRender();
  }

  override render(width: number): string[] {
    const lines = super.render(width);
    if (lines.length === 0) return lines;
    const label = `${this.pending ? `${this.pending}… ` : ""}${this.mode === "normal" ? "NORMAL" : "INSERT"}`;
    const tag = ` ${label} `;
    const last = lines.length - 1;
    if (visibleWidth(lines[last]!) >= tag.length) {
      lines[last] = truncateToWidth(lines[last]!, width - tag.length, "") + tag;
    }
    return lines;
  }
}

export default function (pi: ExtensionAPI) {
  pi.on("session_start", (_event, ctx) => {
    ctx.ui.setEditorComponent(
      (tui, theme, keybindings) => new VimEditor(tui, theme, keybindings),
    );
  });
}
