local M = {}

local function is_truncated(trunc_width)
  local cur_width = vim.o.columns
  return cur_width < (trunc_width or -1)
end

local function is_active()
  return vim.api.nvim_get_current_win() == tonumber(vim.g.actual_currentwin)
end

local function section_path(args)
  if is_truncated(args.trunc_width) then
    return ""
  end

  args = vim.tbl_deep_extend("force", {
    max_depth = 3,
    max_length = 16,
    delimiter = vim.fn.has("win32") == 1 and "\\" or "/",
    -- separator = vim.g.enable_icons and "  " or " > ",
    separator = " > ",
  }, args)

  local buf = vim.api.nvim_get_current_buf()
  local buftype = vim.bo[buf].buftype
  local filetype = vim.bo[buf].filetype
  local bufname = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":t")

  local path = vim.api.nvim_buf_get_name(buf)
  if path == "." or path == "" then
    path = ""
  else
    path = vim.fn.fnamemodify(path, ":.:h")
  end

  local children = {}
  local data = vim.fn.split(path, args.delimiter)

  -- determine if leading ellipsis is needed for truncated path
  local start_idx = 0
  if args.max_depth and args.max_depth > 0 then
    start_idx = #data - args.max_depth
    if start_idx > 0 then
      table.insert(children, (vim.g.enable_icons and "…" or "...")) -- .. args.separator)
    end
  end

  for _, d in ipairs(data) do
    table.insert(children, d)
    -- table.insert(children, args.separator)
  end

  local icon = ""
  local icon_hl = ""
  local ok, devicons = pcall(require, "nvim-web-devicons")
  if ok then
    icon, icon_hl = devicons.get_icon_color(bufname)
    if not icon_hl then
      icon, icon_hl = devicons.get_icon_color_by_filetype(filetype, { default = buftype == "" })
    end
  end

  table.insert(children, string.format("%s %s", icon, bufname))

  return table.concat(children, args.separator)
end

local context_data = {}

local function section_breadcrumbs(args)
  if is_truncated(args.trunc_width) or not is_active() then
    return ""
  end

  args = vim.tbl_deep_extend("force", {
    separator = vim.g.enable_icons and "  " or " > ",
  }, args)

  local buf = vim.api.nvim_get_current_buf()

  -- get symbol location
  -- separate by path

  return ""
end

local function section_tabs_count(args)
  if is_truncated(args.trunc_width) then
    return ""
  end

  local tabs = vim.api.nvim_list_tabpages()
  local count = #tabs

  if count < 2 then
    return ""
  end

  local tabpage = vim.api.nvim_get_current_tabpage()

  return string.format("Tab[%s/%s]", tabpage, count)
end

local function section_buffer_count(args)
  if is_truncated(args.trunc_width) then
    return ""
  end

  local bufs = vim.tbl_filter(function(b)
    return vim.bo[b].buflisted == true and vim.api.nvim_buf_is_valid(b)
  end, vim.api.nvim_list_bufs())

  local count = #bufs
  if count < 2 then
    return ""
  end

  return string.format("Buffers[%s]", count)
end

local function combine_groups(groups)
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

function M.eval()
  local path = section_path({ trunc_width = 75 })
  local breadcrumbs = section_breadcrumbs({ trunc_width = 75 })
  local tabs = section_tabs_count({ trunc_width = 140 })
  local bufs = section_buffer_count({ trunc_width = 140 })

  return combine_groups({
    { strings = { path, breadcrumbs } },
    "%=",
    { strings = { tabs, bufs } },
  })
end

local function setup_highlights()
  local set_default_hl = function(name, data)
    data.default = true
    vim.api.nvim_set_hl(0, name, data)
  end

  set_default_hl("WinbarNormal", { link = "Normal" })
end

local function create_autocmds()
  local group = vim.api.nvim_create_augroup("config_winbar", { clear = true })

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
