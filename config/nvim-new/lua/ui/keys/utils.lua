local M = {}

local state = require("ui.keys.state")

local function is_mouse(x)
  return x:match("Mouse") or x:match("Scroll") or x:match("Drag") or x:match("Release")
end

local function format_mapping(str)
  local keyformat = state.config.keyformat

  local str1 = string.match(str, "<(.-)>")
  if not str1 then
    return str
  end

  local before, after = string.match(str1, "([^%-]+)%-(.+)")
  if before then
    before = "<" .. before .. ">"
    before = keyformat[before] or before
    str1 = before .. " + " .. string.lower(after)
  end

  local str2 = string.match(str, ">(.+)")
  return str1 .. (str2 and (" " .. str2) or "")
end

function M.gen_winconfig()
  local lines = vim.o.lines
  local cols = vim.o.columns
  state.config.winopts.width = state.w

  local pos = state.config.position

  if string.find(pos, "bottom") then
    state.config.winopts.row = lines - 5
  end

  if pos == "top-right" then
    state.config.winopts.col = cols - state.w - 3
  elseif pos == "top-center" or pos == "bottom-center" then
    state.config.winopts.col = math.floor(cols / 2) - math.floor(state.w / 2)
  elseif pos == "bottom-right" then
    state.config.winopts.col = cols - state.w - 3
  end
end

local function update_win_w()
  local len = #state.keys
  state.w = len + 1 + (2 * len)

  for _, v in ipairs(state.keys) do
    state.w = state.w + vim.fn.strwidth(v.txt)
  end

  M.gen_winconfig()
  vim.api.nvim_win_set_config(state.win, state.config.winopts)
end

function M.draw()
  local virt_txts = require("ui.keys.ui")()

  if not state.extmark_id then
    vim.api.nvim_buf_set_lines(state.buf, 0, -1, false, { " " })
  end

  local opts = {
    virt_text = virt_txts,
    virt_text_pos = "overlay",
    id = state.extmark_id,
  }
  local id = vim.api.nvim_buf_set_extmark(state.buf, state.ns, 0, 1, opts)

  if not state.extmark_id then
    state.extmark_id = id
  end
end

function M.redraw()
  update_win_w()
  M.draw()
end

function M.clear_and_close()
  state.keys = {}
  M.redraw()
  local tmp = state.win
  state.win = nil
  vim.api.nvim_win_close(tmp, true)
end

function M.parse_key(char)
  local opts = state.config

  if vim.tbl_contains(opts.excluded_modes, vim.api.nvim_get_mode().mode) then
    if state.win then
      M.clear_and_close()
    end
    return
  end

  local key = vim.fn.keytrans(char)

  if is_mouse(key) or key == "" then
    return
  end

  key = opts.keyformat[key] or key
  key = format_mapping(key)

  local arrlen = #state.keys
  local last_key = state.keys[arrlen]

  if opts.show_count and last_key and key == last_key.key then
    local count = (last_key.count or 1) + 1

    state.keys[arrlen] = {
      key = key,
      txt = count .. " " .. key,
      count = count,
    }
  else
    if arrlen == opts.maxkeys then
      table.remove(state.keys, 1)
    end

    table.insert(state.keys, { key = key, txt = key })
  end

  M.redraw()
end

return M
