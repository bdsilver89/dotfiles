local icons = require("icons")

local M = {}

---@type table<string, boolean>
local hls = {}

---@type table<string, string>
local source_hl = {
  TabuflineBufOn = "TabLineSel",
  TabuflineBuf = "TabLine",
  TabuflineBufOnSep = "TabLineSel",
  TabuflineBufSep = "TabLine",
  TabuflineModified = "DiagnosticWarn",
  TabpageOn = "TabLineSel",
  TabPage = "TabLine",
  Fill = "TabLineFill",
}

---@param hl string
---@return string
local function get_or_create_hl(hl)
  local hl_name = "Tabufline" .. hl
  if not hls[hl] then
    local bg = vim.api.nvim_get_hl(0, { name = "TabLineFill" })
    local fg = vim.api.nvim_get_hl(0, { name = source_hl[hl] or hl })
    vim.api.nvim_set_hl(0, hl_name, { bg = bg.bg, fg = fg.fg or fg.bg })
    hls[hl] = true
  end
  return hl_name
end

---@param buf integer
---@return string icon, string icon_hl
local function get_icons(buf)
  local has_devicons, devicons = pcall(require, "nvim-web-devicons")
  if not has_devicons then
    return "", "Normal"
  end
  local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":t")
  return devicons.get_icon(name, vim.fn.fnamemodify(name, ":e"), { default = true })
end

---@param buf integer
---@param is_current boolean
---@return string
local function render_buf(buf, is_current)
  local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":t")
  if name == "" then
    name = "[No Name]"
  end

  local icon, icon_hl = get_icons(buf)
  local modified = vim.bo[buf].modified

  local base_hl = is_current and "TabuflineBufOn" or "TabuflineBuf"
  local sep_hl = is_current and "TabuflineBufOnSep" or "TabuflineBufSep"

  local parts = {
    string.format("%%#%s#", get_or_create_hl(sep_hl)),
    icons.misc.dashed_bar or "▏",
    string.format(" %%#%s#%s ", get_or_create_hl(icon_hl), icon),
    string.format("%%#%s#%s", get_or_create_hl(base_hl), name),
  }

  if modified then
    table.insert(parts, string.format(" %%#%s#●", get_or_create_hl("TabuflineModified")))
  end

  table.insert(parts, string.format(" %%%d@v:lua.TabuflineCloseClick@%%#%s#×%%X", buf, get_or_create_hl(base_hl)))
  table.insert(parts, " ")

  local body = table.concat(parts)
  return string.format("%%%d@v:lua.TabuflineSwitchClick@%s%%X", buf, body)
end

---@return string
local function render_tabpages()
  local tabs = vim.api.nvim_list_tabpages()
  if #tabs <= 1 then
    return ""
  end

  local current = vim.api.nvim_get_current_tabpage()
  local parts = {}
  for _, tab in ipairs(tabs) do
    local tabnr = vim.api.nvim_tabpage_get_number(tab)
    local win = vim.api.nvim_tabpage_get_win(tab)
    local buf = vim.api.nvim_win_get_buf(win)
    local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":t")
    if name == "" then
      name = "[No Name]"
    end

    local hl = get_or_create_hl(tab == current and "TabpageOn" or "TabPage")
    table.insert(parts, string.format("%%%dT %%#%s#%d %s %%T", tabnr, hl, tabnr, name))
  end

  return table.concat(parts) .. string.format("%%#%s#", get_or_create_hl("Fill"))
end

function M.render()
  local bufs = vim.tbl_filter(function(b)
    return b.listed == 1 and vim.bo[b.bufnr].buftype == ""
  end, vim.fn.getbufinfo())

  table.sort(bufs, function(a, b)
    return a.bufnr < b.bufnr
  end)

  local current = vim.api.nvim_get_current_buf()
  local entries = vim
    .iter(bufs)
    :map(function(b)
      return render_buf(b.bufnr, b.bufnr == current)
    end)
    :totable()

  return table.concat(entries) .. string.format("%%#%s#%%=", get_or_create_hl("Fill")) .. render_tabpages()
end

function _G.TabuflineSwitchClick(bufnr, _, button)
  if button == "l" then
    vim.api.nvim_set_current_buf(bufnr)
  end
end

function _G.TabuflineCloseClick(bufnr)
  vim.schedule(function()
    if vim.bo[bufnr].modified then
      vim.notify("buffer has unsaved changes", vim.log.levels.WARN)
      return
    end
    vim.api.nvim_buf_delete(bufnr, {})
  end)
end

vim.o.tabline = "%!v:lua.require'tabufline'.render()"
vim.o.showtabline = 2

vim.api.nvim_create_autocmd({ "BufAdd", "BufDelete", "BufEnter", "BufModifiedSet" }, {
  group = vim.api.nvim_create_augroup("tabufline", { clear = true }),
  callback = function()
    vim.schedule(function()
      vim.cmd.redrawtabline()
    end)
  end,
})

return M
