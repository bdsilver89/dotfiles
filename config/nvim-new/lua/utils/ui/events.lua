local M = {}

local state = require("utils.ui.state")

M.bufs = {}

local function get_item_from_col(tb, n)
  for _, val in ipairs(tb) do
    if val.col_start <= n and val.col_end >= n then
      return val
    end
  end
end

local function run_func(fn)
  if type(fn) == "function" then
    fn()
  elseif type(fn) == "string" then
    vim.cmd(fn)
  end
end

local function handle_click(buf, by, row, col, win)
  local v = state[buf]

  if not row then
    local cursor_pos = vim.api.nvim_win_get_cursor(0)
    row, col = cursor_pos[1], cursor_pos[2]
  end

  if v.clickables[row] then
    local virt = get_item_from_col(v.clickables[row], col)

    if virt and (by ~= "keyb" or virt.ui_type == "slider") then
      local action = virt.actions
      -- if virt
    end
  end
end

local function handle_hover(buf_state, buf, row, col) end

local function buf_mappings(buf)
  vim.api.nvim_create_autocmd("CursorMoved", {
    buffer = buf,
    callback = function()
      handle_click(buf, "keyb")
    end,
  })

  vim.keymap.set("n", "<cr>", function()
    handle_click(buf)
  end, { buffer = buf })

  vim.keymap.set("n", "<tab>", function()
    cycle_clickables(buf, 1)
  end, { buffer = buf })

  vim.keymap.set("n", "<s-tab>", function()
    cycle_clickables(buf, -1)
  end, { buffer = buf })
end

function M.add(val)
  if type(val) == "table" then
    for _, buf in ipairs(val) do
      table.insert(M.bufs, buf)
      buf_mappings(buf)
    end
  else
    table.insert(M.bufs, val)
    buf_mappings(val)
  end
end

function M.enable()
  vim.g.extmarks_events = true
  vim.o.mousemev = true

  vim.on_key(function(key)
    local mousepos = vim.fn.getmousepos()
    local cur_win = mousepos.winid
    local cur_buf = vim.api.nvim_win_get_buf(cur_win)

    if vim.tbl_contains(M.bufs, cur_buf) then
      local row, col = mousepos.line, mousepos.column - 1

      if key == MouseMove then
        handle_hover(state[cur_buf], cur_buf, row, col)
      elseif key == LeftMouse then
        handle_click(cur_buf, "mouse", row, col, cur_win)
      end
    end
  end)
end

return M


