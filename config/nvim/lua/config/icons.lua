local M = {}

local nerd_icons = {
  misc = {
    Dots = "󰇘",
    Settings = " ",
    Modified = "● ",
    Readonly = " ",
    Terminal = " ",
    TS = " ",
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
  kinds = {
    Array = " ",
    Boolean = "󰨙 ",
    Class = " ",
    Codeium = "󰘦 ",
    Color = " ",
    Control = " ",
    Collapsed = " ",
    Constant = "󰏿 ",
    Constructor = " ",
    Copilot = " ",
    Enum = " ",
    EnumMember = " ",
    Event = " ",
    Field = " ",
    File = " ",
    Folder = " ",
    Function = "󰊕 ",
    Interface = " ",
    Key = " ",
    Keyword = " ",
    Method = "󰊕 ",
    Module = " ",
    Namespace = "󰦮 ",
    Null = " ",
    Number = "󰎠 ",
    Object = " ",
    Operator = " ",
    Package = " ",
    Property = " ",
    Reference = " ",
    Snippet = " ",
    String = " ",
    Struct = "󰆼 ",
    TabNine = "󰏚 ",
    Text = " ",
    TypeParameter = " ",
    Unit = " ",
    Value = " ",
    Variable = "󰀫 ",
  },
}

local text_icons = {
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
  kinds = {},
}

M.icons = (vim.g.enable_icons ~= false) and nerd_icons or text_icons

---@param group string
---@param name string
---@param no_fallback? boolean
---@return string
function M.get_icon(group, name, no_fallback)
  local icons_enabled = vim.g.enable_icons ~= false
  if not icons_enabled and no_fallback then
    return ""
  end
  local selected_icons = icons_enabled and nerd_icons or text_icons

  local icon_group = selected_icons[group] or {}
  return icon_group[name] or "" --[[@as string]]
end

---@oaram group string
---@oaram no_fallback? boolean
---@return table|nil
function M.get_icon_group(group, no_fallback)
  local icons_enabled = vim.g.enable_icons ~= false
  if not icons_enabled and no_fallback then
    return {}
  end
  local selected_icons = icons_enabled and nerd_icons or text_icons
  return selected_icons[group] or {}
end

return M
