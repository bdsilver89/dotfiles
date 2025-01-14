local icons = {
  misc = {
    vim = " ",
    large_circle = " ",
    small_circle = "●",
    rounded_square = "󱓻 ",
    folder = "󰉖 ",
  },
  spinners = { "", "󰪞", "󰪟", "󰪠", "󰪡", "󰪢", "󰪣", "󰪤", "󰪥", "" },
  dap = {
    Stopped = { "󰁕 ", "DiagnosticWarn", "DapStoppedLine" },
    Breakpoint = " ",
    BreakpointCondition = " ",
    BreakpointRejected = { " ", "DiagnosticError" },
    LogPoint = "◆",
  },
  diagnostics = {
    error = " ",
    warn = " ",
    hint = " ",
    info = " ",
  },
  git = {
    branch = "",
    added = " ",
    modified = " ",
    removed = " ",
  },
  separators = {
    rounded = {
      left = "",
      right = "",
    },
    rounded_outline = {
      left = "",
      right = "",
    },
  },
}

local text = {
  misc = {
    vim = "",
    large_circle = "",
    small_circle = "",
    rounded_square = "",
    folder = "",
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
    error = "E",
    warn = "W",
    hint = "H",
    info = "I",
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
    rounded_outline = {
      left = "",
      right = "",
    },
  },
}

return vim.g.has_nerd_font and icons or text
