local icons = {
  misc = {
    large_circle = " ",
    small_circle = "●",
    rounded_square = "󱓻 ",
    separator = "",
  },
  spinners = { "", "󰪞", "󰪟", "󰪠", "󰪡", "󰪢", "󰪣", "󰪤", "󰪥", "" },
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
    branch = "",
    added = " ",
    modified = " ",
    removed = " ",
  },
  separators = {
    rounded = {
      left = "",
      right = "",
    },
  },
}

local text = {
  misc = {
    large_circle = "",
    small_circle = "",
    rounded_square = "",
  },
  spinners = { "", "", "", "", "", "", "", "", "", "" },
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
    branch = "",
    added = "+",
    modified = "~",
    removed = "-",
  },
  separators = {
    rounded = {
      left = "",
      right = "",
    },
  },
}

return vim.g.has_nerd_font and icons or text
