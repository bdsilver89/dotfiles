import type { Plugin } from "@opencode-ai/plugin";

export const WorkmuxStatusPlugin: Plugin = async ({ $ }) => {
  const lastStatusBySession = new Map<string, string>();
  const acceptBusyBySession = new Map<string, boolean>();

  // tag this pane as opencode immediately so it doesn't linger showing
  // whatever tool last ran here (e.g. claude) until the first status event
  await $`tmux-agent-status working opencode`.quiet();

  async function setStatus(sessionID: string | undefined, status: string) {
    if (!sessionID) {
      return;
    }

    const previous = lastStatusBySession.get(sessionID);
    if (status === "working" && acceptBusyBySession.get(sessionID) === false) {
      return;
    }
    if (previous === status) {
      return;
    }

    lastStatusBySession.set(sessionID, status);
    if (status === "done") {
      acceptBusyBySession.set(sessionID, false);
    } else {
      acceptBusyBySession.set(sessionID, true);
    }

    await $`tmux-agent-status ${status} opencode`.quiet();
  }

  return {
    event: async ({ event }) => {
      if (
        event.type === "message.updated" &&
        event.properties.info.role === "user"
      ) {
        acceptBusyBySession.set(event.properties.sessionID, true);
      }

      switch (event.type) {
        case "session.status":
          if (event.properties.status.type === "busy") {
            await setStatus(event.properties.sessionID, "working");
          }
          if (event.properties.status.type === "idle") {
            await setStatus(event.properties.sessionID, "done");
          }
          break;
        case "permission.asked":
        case "question.asked":
          await setStatus(event.properties.sessionID, "waiting");
          break;
        case "permission.replied":
        case "question.replied":
          await setStatus(event.properties.sessionID, "working");
          break;
        case "session.idle":
          await setStatus(event.properties.sessionID, "done");
          break;
      }
    },
  };
};
