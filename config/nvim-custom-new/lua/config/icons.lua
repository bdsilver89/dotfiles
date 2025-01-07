local icons = {
  dap = {
    Stopped = { "󰁕 ", "DiagnosticWarn", "DapStoppedLine" },
    Breakpoint = " ",
    BreakpointCondition = " ",
    BreakpointRejected = { " ", "DiagnosticError" },
    LogPoint = ".>",
  },
  diagnostics = {
    Error = " ",
    Warn = " ",
    Hint = " ",
    Info = " ",
  },
  git = {
    added = " ",
    modified = " ",
    removed = " ",
  },
}

local text = {
  dap = {
    Stopped = { ">", "DiagnosticWarn", "DapStoppedLine" },
    Breakpoint = "*",
    BreakpointCondition = "?",
    BreakpointRejected = { "!", "DiagnosticError" },
    LogPoint = ".>",
  },
  diagnostics = {
    Error = "E",
    Warn = "W",
    Hint = "H",
    Info = "I",
  },
  git = {
    added = "+",
    modified = "~",
    removed = "-",
  },
}

return vim.g.has_nerd_font and icons or text
