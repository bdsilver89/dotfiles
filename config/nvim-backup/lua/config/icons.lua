vim.g.has_nerd_icons = true

if vim.g.has_nerd_icons then
  return {
    diagnostics = {
      ERROR = " ",
      WARN = " ",
      HINT = " ",
      INFO = " ",
    },
    dap = {
      Stopped = { "󰁕 ", "DiagnosticWarn", "DapStoppedLine" },
      Breakpoint = " ",
      BreakpointCondition = " ",
      BreakpointRejected = { " ", "DiagnosticError" },
      LogPoint = ".>",
    },
    git = {
      added = " ",
      modified = " ",
      removed = " ",
    },
    misc = {
      bug = "",
      ellipsis = "…",
      git = " ",
      search = "",
      vertical_bar = "│",
      dashed_bar = "┊",
    },
  }
else
  return {
    diagnostics = {
      ERROR = "E",
      WARN = "W",
      HINT = "H",
      INFO = "I",
    },
    dap = {
      Stopped = { "-> ", "DiagnosticWarn", "DapStoppedLine" },
      Breakpoint = "B ",
      BreakpointCondition = "B? ",
      BreakpointRejected = { "B! ", "DiagnosticError" },
      LogPoint = ".>",
    },
    git = {
      added = "+ ",
      modified = "~ ",
      removed = "- ",
    },
    misc = {
      bug = "",
      ellipsis = "...",
      git = "",
      search = "",
      vertical_bar = "|",
      dashed_bar = "|",
    },
  }
end
