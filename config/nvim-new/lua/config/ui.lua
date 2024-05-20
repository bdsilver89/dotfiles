local M = {}

local icons = {
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
    Array         = " ",
    Boolean       = "󰨙 ",
    Class         = " ",
    Codeium       = "󰘦 ",
    Color         = " ",
    Control       = " ",
    Collapsed     = " ",
    Constant      = "󰏿 ",
    Constructor   = " ",
    Copilot       = " ",
    Enum          = " ",
    EnumMember    = " ",
    Event         = " ",
    Field         = " ",
    File          = " ",
    Folder        = " ",
    Function      = "󰊕 ",
    Interface     = " ",
    Key           = " ",
    Keyword       = " ",
    Method        = "󰊕 ",
    Module        = " ",
    Namespace     = "󰦮 ",
    Null          = " ",
    Number        = "󰎠 ",
    Object        = " ",
    Operator      = " ",
    Package       = " ",
    Property      = " ",
    Reference     = " ",
    Snippet       = " ",
    String        = " ",
    Struct        = "󰆼 ",
    TabNine       = "󰏚 ",
    Text          = " ",
    TypeParameter = " ",
    Unit          = " ",
    Value         = " ",
    Variable      = "󰀫 ",
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

---@param group string
---@param name string
---@param no_fallback? boolean
---@return string
function M.get_icon(group, name, no_fallback)
  local icons_enabled = vim.g.icons_enabled ~= false
  if not icons_enabled and no_fallback then
    return ""
  end
  local selected_icons = icons_enabled and icons or text_icons

  local icon_group = selected_icons[group] or {}
  return icon_group[name] or "" --[[@as string]]
end

---@oaram group string
---@oaram no_fallback? boolean
---@return table|nil
function M.get_icon_group(group, no_fallback)
  local icons_enabled = vim.g.icons_enabled ~= false
  if not icons_enabled and no_fallback then
    return {}
  end
  local selected_icons = icons_enabled and icons or text_icons
  return selected_icons[group] or {}
end

local function get_signs(buf, lnum)
  local signs = {}

  if vim.fn.has("nvim-0.10") == 0 then
    for _, sign in ipairs(vim.fn.sign_getplaced(buf, { group = "*", lnum = lnum })[1].signs) do
      local ret = vim.fn.sign_getdefined(sign.name)[1]
      if ret then
        ret.priority = sign.priority
        signs[#signs + 1] = ret
      end
    end
  end

  local extmarks = vim.api.nvim_buf_get_extmarks(
    buf,
    -1,
    { lnum - 1, 0 },
    { lnum - 1, -1 },
    { details = true, type = "sign" })
  for _, extmark in pairs(extmarks) do
    signs[#signs + 1] = {
      name = extmark[4].sign_hl_group or "",
      text = extmark[4].sign_text,
      texthl = extmark[4].sign_hl_group,
      priority = extmark[4].priority,
    }
  end

  table.sort(signs, function(first, second)
    return (first.priority or 0) < (second.priority or 0)
  end)
  return signs
end

local function get_mark(buf, lnum)
  local marks = vim.fn.getmarklist(buf)
  vim.list_extend(marks, vim.fn.getmarklist())
  for _, mark in ipairs(marks) do
    if mark.pos[1] == buf and mark.pos[2] == lnum and mark.mark:match('[a-zA-Z]') then
      return { text = mark.mark:sub(2), texthl = "DiagnosticHint" }
    end
  end
end

local function icon(sign, len)
  sign = sign or {}
  len = len or 2
  local text = vim.fn.strcharpart(sign.text or "", 0, len)
  text = text .. string.rep(" ", len - vim.fn.strchars(text))
  return sign.texthl and ("%#" .. sign.texthl .. "#" .. text .. "%*") or text
end

function M.statuscolumn()
  local win = vim.g.statusline_winid
  local buf = vim.api.nvim_win_get_buf(win)
  local is_file = vim.bo[buf].buftype == ""
  local show_signs = vim.wo[win].signcolumn ~= "no"

  local components = { "", "", "" }

  if show_signs then
    local left, right, fold
    for _, s in ipairs(get_signs(buf, vim.v.lnum)) do
      if s.name and (s.name:find("GitSign")) then
        right = s
      else
        left = s
      end
    end

    if vim.v.virtnum ~= 0 then
      left = nil
    end
    vim.api.nvim_win_call(win, function()
      if vim.fn.foldclosed(vim.v.lnum) >= 0 then
        fold = { text = vim.opt.fillchars:get().foldclose or "", texthl = "Folded" }
      end
    end)

    components[1] = icon(get_mark(buf, vim.v.lnum) or left)
    components[3] = is_file and icon(fold or right) or ""
  end

  local is_num = vim.wo[win].number
  local is_relnum = vim.wo[win].relativenumber
  if (is_num or is_relnum) and vim.v.virtnum == 0 then
    if vim.v.relnum == 0 then
      components[2] = is_num and "%l" or "%r"
    else
      components[2] = is_relnum and "%r" or "%l"
    end
    components[2] = "%=" .. components[2] .. " "
  end

  return table.concat(components, "")
end

return M
