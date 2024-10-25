local M = {}

local function is_truncated(trunc_width)
  local cur_width = vim.o.columns
  return cur_width < (trunc_width or -1)
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

local function section_path(args)
  if is_truncated(args.trunc_width) then
    return "%f%m%r"
  else
    return "%F%m%r"
  end
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
  local path = section_path({ trunc_width = 140 })
  local tabs = section_tabs_count({ trunc_width = 75 })
  local bufs = section_buffer_count({ trunc_width = 75 })

  return combine_groups({
    { strings = { path } },
    "%=",
    { strings = { tabs, bufs } },
  })
end

function M.setup()
  -- TODO
end

return M
