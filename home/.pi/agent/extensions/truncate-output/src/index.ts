import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { isBashToolResult } from "@earendil-works/pi-coding-agent";

export default function (pi: ExtensionAPI): void {
  const config = loadConfig(process.cwd());
  const registry = createRegistry(config);
  const engine = new FilterEngine(registry);
  const sessionId = Date.now();

  pi.on("tool_result", (event, ctx) => {
    if (!isBashToolResult(event)) return;
    if (event.isError) return;

    const command = event.input.command;
    if (typeof command !== "string") return;

    const textParts: string[] = [];
  });
}
