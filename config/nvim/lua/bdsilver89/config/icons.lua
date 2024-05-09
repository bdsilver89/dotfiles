local M = {}

M.icons = {
  misc = {
    Dots = "󰇘",
    Settings = " ",
    Modified = "●",
    Readonly = "",
  },
  separators = {
    LeftSlant = "",
    RightSlant = "",
  },
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
    Added = " ",
    Changed = " ",
    Removed = " ",
    Branch = " ",
  },
  gitsigns = {
    Add = "▎",
    Change = "▎",
    Delete = "",
    TopDelete = "",
    ChangeDelete = "▎",
    Untracked = "▎",
  },
  telescope = {
    PromptPrefix = " ",
    SelectionCaret = " ",
  },
}

M.text_icons = {
  misc = {
    Modified = "[+]",
  },
  dap = {
    Stopped = { ">", "DiagnosticWarn", "DapStoppedLine" },
    Breakpoint = "B",
    BreakpointCondition = "B?",
    BreakpointRejected = { "B!", "DiagnosticError" },
    LogPoint = ".>",
  },
  diagnostics = {
    Error = "X ",
    Warn = "! ",
    Hint = "? ",
    Info = "i ",
  },
  git = {
    Added = "[+]",
    Changed = "[~]",
    Removed = "[-]",
  },
  gitsigns = {
    Add = "+",
    Change = "~",
    Delete = "_",
    TopDelete = "‾",
    ChangeDelete = "~",
  },
  telescope = {
    PromptPrefix = "> ",
    SelectionCaret = "> ",
  },
}

return M
