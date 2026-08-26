import type { Extension } from "@earendil-works/pi-coding-agent";

export default function agentStatus(pi: Extension) {
  // tag this pane as pi immediately so it doesn't linger showing whatever
  // tool last ran here until the first agent_start event
  Bun.spawn(["tmux-agent-status", "working", "pi"]);

  pi.on("agent_start", async (_e, ctx) => {
    await ctx.exec("tmux-agent-status", ["working", "pi"]);
  });
  pi.on("agent_settled", async (_e, ctx) => {
    await ctx.exec("tmux-agent-status", ["done", "pi"]);
  });
  pi.on("tool_call", async (event, ctx) => {
    if (event.requiresConfirmation) {
      await ctx.exec("tmux-agent-status", ["waiting", "pi"]);
    }
  });
}
