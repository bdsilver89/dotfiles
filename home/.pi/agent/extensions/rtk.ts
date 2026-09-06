import { isToolCallEventType, type ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  pi.on("tool_call", async (event, ctx) => {
    if (!isToolCallEventType("bash", event)) return;

    const command = event.input.command;

    let rewritten = "";
    try {
      // A throw here would block the bash call entirely, so rtk being absent,
      // broken, or slow must degrade to running the original command.
      const { stdout } = await pi.exec("rtk", ["rewrite", command], { timeout: 3000 });
      // `rtk rewrite` signals "no equivalent" with empty stdout, not exit code.
      rewritten = stdout.trim();
    } catch {
      return;
    }

    if (rewritten && rewritten !== command) {
      event.input.command = rewritten;
      // Notify rather than annotate the model's output: a rewrite changes the
      // shape of the result, and silently returning a different format than the
      // command implies is easy to misread as the real tool's output.
      if (ctx.hasUI) {
        ctx.ui.notify(`rtk -> ${rewritten}`, "info");
      }
    }
  });
}
