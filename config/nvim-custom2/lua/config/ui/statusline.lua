local M = {}

local CTRL_S = vim.api.nvim_replace_termcodes('<C-S>', true, true, true)
local CTRL_V = vim.api.nvim_replace_termcodes('<C-V>', true, true, true)

-- stylua: ignore start
local modes = setmetatable({
  ['n']    = { long = 'Normal',   short = 'N',   hl = 'StatuslineModeNormal' },
  ['v']    = { long = 'Visual',   short = 'V',   hl = 'StatuslineModeVisual' },
  ['V']    = { long = 'V-Line',   short = 'V-L', hl = 'StatuslineModeVisual' },
  [CTRL_V] = { long = 'V-Block',  short = 'V-B', hl = 'StatuslineModeVisual' },
  ['s']    = { long = 'Select',   short = 'S',   hl = 'StatuslineModeVisual' },
  ['S']    = { long = 'S-Line',   short = 'S-L', hl = 'StatuslineModeVisual' },
  [CTRL_S] = { long = 'S-Block',  short = 'S-B', hl = 'StatuslineModeVisual' },
  ['i']    = { long = 'Insert',   short = 'I',   hl = 'StatuslineModeInsert' },
  ['R']    = { long = 'Replace',  short = 'R',   hl = 'StatuslineModeReplace' },
  ['c']    = { long = 'Command',  short = 'C',   hl = 'StatuslineModeCommand' },
  ['r']    = { long = 'Prompt',   short = 'P',   hl = 'StatuslineModeOther' },
  ['!']    = { long = 'Shell',    short = 'Sh',  hl = 'StatuslineModeOther' },
  ['t']    = { long = 'Terminal', short = 'T',   hl = 'StatuslineModeOther' },
}, {
  -- By default return 'Unknown' but this shouldn't be needed
  __index = function()
    return   { long = 'Unknown',  short = 'U',   hl = '%#StatuslineModeOther#' }
  end,
})
-- stylua: ignore end

local function is_truncated(trunc_width)
  local cur_width = vim.o.laststatus == 3 and vim.o.columns or vim.api.nvim_get_width(0)
  return cur_width < (trunc_width or -1)
end

local function section_mode(args)
  local m = modes[vim.fn.mode()]

  local mname = is_truncated(args.trunc_width) and m.short or m.long

  return mname, m.hl
end

local function section_git(args)
  if is_truncated(args.trunc_width) then
    return ""
  end

  local summary = vim.b.minigit_summary_string or vim.b.gitsigns_head
  if summary == nil then
    return ''
  end

  local icon = vim.g.enable_icons and "" or "Git"
  return icon .. ' ' .. (summary == '' and '-' or summary)
end

local function section_diff(args)
  if is_truncated(args.trunc_width) then
    return ""
  end

  local summary = vim.b.minidiff_summary_string or vim.b.gitsigns_status
  if summary == nil then
    return ""
  end

  local icon = vim.g.enable_icons and '' or 'Diff'
  return icon .. ' ' .. (summary == '' and '-' or summary)
end

local diagnostic_levels = {
  { name = 'ERROR', sign = 'E' },
  { name = 'WARN', sign = 'W' },
  { name = 'INFO', sign = 'I' },
  { name = 'HINT', sign = 'H' },
}

local function section_diagnostics(args)
  if is_truncated(args.trunc_width) or not vim.diagnostic.is_enabled({ bufnr = 0 }) then
    return ""
  end

  local count = vim.diagnostic.count(0)
  local signs = args.signs or {}
  local t = {}
  for _, level in ipairs(diagnostic_levels) do
    local n = count[vim.diagnostic.severity[level.name]] or 0
    if n > 0 then
      table.insert(t, " " .. (signs[level.name] or level.sign) .. n)
    end
  end

  if #t == 0 then
    return ""
  end

  local icon = vim.g.enable_icons and "" or "Diag"
  return icon .. table.concat(t, "")
end

local attached_lsp = {}

local function section_lsp(args)
  if is_truncated(args.trunc_width) then
    return ""
  end

  local attached = attached_lsp[vim.api.nvim_get_current_buf()] or ""
  if attached == "" then
    return ""
  end

  local icon = vim.g.enable_icons and "󰰎" or "LSP"
  return icon .. " " .. attached
end

local spinners = { "", "", "", "󰪞", "󰪟", "󰪠", "󰪢", "󰪣", "󰪤", "󰪥" }
local lsp_msg_state = ""
local function section_lsp_msg(args)
  if is_truncated(args.trunc_width) then
    return ""
  end
  return lsp_msg_state
end

local function section_filename(args)
  if vim.bo.buftype == "terminal" then
    return "%t"
  elseif is_truncated(args.trunc_widtH) then
    return "%f%m%r"
  else
    return "%F%m%r"
  end
end

local function section_fileinfo(args)
  local filetype = vim.bo.filetype
  if filetype == "" then
    return ""
  end

  if vim.g.enable_icons then
    local has_devicons, devicons = pcall(require, "nvim-web-devicons")
    if has_devicons then
      local icon = devicons.get_icon(vim.fn.expand("%:t"), nil, { default = true })
      filetype = icon .. " " .. filetype
    end
  end

  if is_truncated(args.trunc_width) or vim.bo.buftype ~= "" then
    return filetype
  end

  local encoding = vim.bo.fileencoding or vim.bo.encoding
  local format = vim.bo.fileformat
  local size = ""

  return string.format("%s %s[%s] %s", filetype, encoding, format, size)
end

local function section_location(args)
  if is_truncated(args.trunc_width) then
    return "%l:%c"
  end

  return "%l:%c %p %%"
end

local function section_search(args)
  if vim.v.hlsearch == 0 or is_truncated(args.trunc_width) then
    return ""
  end

  local ok, scount = pcall(vim.fn.searchcount, (args or {}).options or { recompute = true })
  if not ok or scount == nil or scount.total == 0 then
    return ""
  end

  if scount.incomplete == 1 then
    return "?/?"
  end

  local too_many = ">" .. scount.maxcount
  local current = scount.current > scount.maxcount and too_many or scount.current
  local total = scount.total > scount.maxcount and too_many or scount.total
  return current .. "/" .. total
end

function M.eval()
  -- stylua: ignore start
  local mode, mode_hl = section_mode({ trunc_width = 120 })
  local git           = section_git({ trunc_width = 40 })
  local diff          = section_diff({ trunc_width = 75 })
  local diagnostics   = section_diagnostics({ trunc_width = 75 })
  local lsp_msg       = section_lsp_msg({ trunc_width = 75 })
  local lsp           = section_lsp({ trunc_width = 75 })
  local filename      = section_filename({ trunc_width = 140 })
  local fileinfo      = section_fileinfo({ trunc_width = 120 })
  local location      = section_location({ trunc_width = 75 })
  local search        = section_search({ trunc_width = 75 })

  local groups = {
    { hl = mode_hl,              strings = { mode } },
    { hl = "StatuslineDevInfo",  strings = { git, diff } },
    "%<",
    { hl = "StatuslineFilename", strings = { filename } },
    "%=",
    { hl = "StatuslineFilename", strings = { lsp_msg } },
    { hl = "StatuslineDevInfo",  strings = { diagnostics, lsp } },
    { hl = "StatuslineFileInfo", strings = { fileinfo } },
    { hl = mode_hl,              strings = { search, location } },
  }
  -- stylua: ignore end

  local parts = vim.tbl_map(function(s)
    if type(s) == "string" then
      return s
    end
    if type(s) ~= "table" then
      return ""
    end

    local string_arr = vim.tbl_filter(function(x)
      return type(x) == "string" and x ~= ""
    end, s.strings or {})
    local str = table.concat(string_arr, " ")

    if s.hl == nil then
      return " " .. str .. " "
    end

    if str:len() == 0 then
      return "%#" .. s.hl .. "#"
    end

    return string.format("%%#%s# %s ", s.hl, str)
  end, groups)

  return table.concat(parts, " ")
end

local function setup_highlights()
  local set_default_hl = function(name, data)
    data.default = true
    vim.api.nvim_set_hl(0, name, data)
  end

  set_default_hl('StatuslineModeNormal',  { link = 'Cursor' })
  set_default_hl('StatuslineModeInsert',  { link = 'DiffChange' })
  set_default_hl('StatuslineModeVisual',  { link = 'DiffAdd' })
  set_default_hl('StatuslineModeReplace', { link = 'DiffDelete' })
  set_default_hl('StatuslineModeCommand', { link = 'DiffText' })
  set_default_hl('StatuslineModeOther',   { link = 'IncSearch' })

  set_default_hl('StatuslineDevinfo',  { link = 'StatusLine' })
  set_default_hl('StatuslineFilename', { link = 'StatusLineNC' })
  set_default_hl('StatuslineFileinfo', { link = 'StatusLine' })
end

local function create_autocmds()
  local group = vim.api.nvim_create_augroup("config_statusline", { clear = true })

  local function autocmd(event, pattern, callback, desc)
    vim.api.nvim_create_autocmd(event, { group = group, pattern = pattern, callback = callback, desc = desc })
  end

  autocmd({ "LspAttach", "LspDetach" }, "*", function(args)
    attached_lsp[args.buf] = string.rep("+", vim.tbl_count(vim.lsp.get_clients({ bufnr = args.buf })))
    vim.cmd.redrawstatus()
  end, "Track LSP clients")

  autocmd("LspProgress", "*", function(args)
    local data = args.data.params.value
    local progress = ""

    if data.percentage then
      local idx = math.max(1, math.floor(data.percentage / 10))
      local icon = vim.g.enable_icons and (spinners[idx] .. " ") or ""
      progress = icon .. data.percentage .. "%% "
    end

    local str =  progress .. (data.message or "") .. " " .. (data.title or "")
    lsp_msg_state = data.kind == "end" and "" or str
    vim.cmd.redrawstatus()
  end, "Track LSP messages")

  autocmd("ColorScheme", "*", setup_highlights, "Update colors")
end

function M.setup()
  vim.g.qf_disable_statusline = 1

  create_autocmds()
  setup_highlights()
end

return M
