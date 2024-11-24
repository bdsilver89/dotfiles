local M = {}

local path_sep = package.config:sub(1, 1)

local function construct_highlight(buf)
  local hl_type
  if buf == vim.api.nvim_get_current_buf() then
    hl_type = "Current"
  elseif vim.fn.bufwinnr(buf) > 0 then
    hl_type = "Visible"
  else
    hl_type = "Hidden"
  end

  if vim.bo[buf].modified then
    hl_type = "Modified" .. hl_type
  end

  return string.format("%%#Tabline%s#", hl_type)
end

local function construct_tabfunc(buf)
  return ""
end

local function construct_label(buf)
  local label, extender

  local bufname = vim.api.nvim_buf_get_name(buf)
  if bufname ~= "" then
    label = vim.fn.fnamemodify(bufname, ":t")
    extender = function(x)
      local fp = vim.api.nvim_buf_get_name(x)
      local pattern = string.format("[^%s]+%s%s$", vim.pesc(path_sep), vim.pesc(path_sep), vim.pesc(x))
      return string.match(fp, pattern) or x
    end
  else
    if vim.bo[buf].buftype == "quickfix" then
      label = "quickfix"
    elseif vim.bo[buf].buftype == "acwrite" or vim.bo[buf].buftype == "nofile" then
      label = "!"
    else
      label = "*"
    end

    -- TODO: unnamed buffer id

    extender = function(x)
      return x
    end
  end

  return label, extender
end

function M.eval()
  local tabpage_section = ""
  local n_tabpages = vim.fn.tabpagenr("$")
  if n_tabpages == 1 then
    tabpage_section = ""
  else
    local cur_tabpage = vim.fn.tabpagenr()
    tabpage_section = (" Tab %s/%s"):format(cur_tabpage, n_tabpages)
  end

  local tabs = {}
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[buf].buflisted then
      local tab = {
        buf = buf,
        hl = construct_highlight(buf),
        tabfunc = construct_tabfunc(buf),
        label = "",
      }

      local bufname = vim.api.nvim_buf_get_name(buf)

      local has_devicons, devicons = pcall(require, "nvim-web-devicons")
      if has_devicons then
        local icon = devicons.get_icon(vim.fn.fnamemodify(bufname, ":t"))
        tab.label = (" %s %s "):format(icon, "NAME")
      else
        tab.label = (" %s "):format("NAME")
      end

      table.insert(tabs, tab)
    end
  end

  local t = {}
  for _, tab in ipairs(tabs) do
    table.insert(t, ("%s%s%s"):format(tab.hl, tab.tabfunc, tab.label:gsub("%%", "%%%%")))
  end

  return ("%s%%X%%#TablineFill#%%=%%#TablineTabpageSection#%s"):format(table.concat(t, ""), tabpage_section)
end

local function setup_highlights()
  local set_default_hl = function(name, data)
    data.default = true
    vim.api.nvim_set_hl(0, name, data)
  end

  set_default_hl("TablineCurrent", { link = "TabLineSel" })
  set_default_hl("TablineVisible", { link = "TabLineSel" })
  set_default_hl("TablineHidden", { link = "TabLine" })
  set_default_hl("TablineModifiedCurrent", { link = "StatusLine" })
  set_default_hl("TablineModifiedVisible", { link = "StatusLine" })
  set_default_hl("TablineModifiedHidden", { link = "StatusLineNC" })
  set_default_hl("TablineTabpageSection", { link = "Search" })
  set_default_hl("TablineFill", { link = "Normal" })
end

local function create_autocmds()
  local group = vim.api.nvim_create_augroup("config_tabline", { clear = true })

  local function autocmd(event, pattern, callback, desc)
    vim.api.nvim_create_autocmd(event, { group = group, pattern = pattern, callback = callback, desc = desc })
  end

  autocmd("ColorScheme", "*", setup_highlights, "Update colors")
end

function M.setup()
  create_autocmds()
  setup_highlights()
end

return M
