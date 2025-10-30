local M = {}

local state = require("utils.ui.state")
local utils = require("utils.ui.utils")

local function draw(buf, section)
  local v = state[buf]
  local section_lines = section.lines(buf)
  local xpad = section.col_start or v.xpad or 0

  for line_i, val in ipairs(section_lines) do
    local row = line_i + section.row
    local col = xpad

    v.clickables[row] = {}
    v.hoverables[row] = {}

    for _, mark in ipairs(val) do
      local strlen = vim.fn.strwidth(mark[1])
      col = col + strlen

      if mark[3] then
        local virt = {
          col_start = col - strlen,
          col_end = col,
          actions = mark[3],
        }

        if strlen == 1 and #mark[1] == 1 then
          virt.col_end = virt.col_start
        end

        table.insert(v.clickables[row], virt)

        if type(virt.actions) == "table" then
          virt.ui_type = virt.actions.ui_type
          virt.hover = virt.actions.hover
          table.insert(v.hoverables[row], virt)
        end
      end
    end
  end

  for _, line in ipairs(section_lines) do
    for _, marks in ipairs(line) do
      table.remove(marks, 3)
    end
  end

  for line, marks in ipairs(section_lines) do
    local row = line + section.row
    local opts = { virt_text_win_col = xpad, virt_text = marks, id = row }
    vim.api.nvim_buf_set_extmark(buf, v.ns, row - 1, 0, opts)
  end
end

local function get_section(tb, name)
  for _, value in ipairs(tb) do
    if value.name == name then
      return value
    end
  end
end

function M.gen_data(data)
  for _, info in ipairs(data) do
    state[info.buf] = {}

    local buf = info.buf
    local v = state[buf]

    v.clickables = {}
    v.hoverables = {}
    v.xpad = info.xpad
    v.layout = info.layout
    v.ns = info.ns
    v.buf = buf

    local row = 0

    for _, value in ipairs(v.layout) do
      local lines = value.lines(buf)
      value.row = row
      row = row + #lines
    end

    v.h = row
  end
end

function M.redraw(buf, names)
  local v = state[buf]

  if names == "all" then
    for _, section in ipairs(v.layout) do
      draw(buf, section)
    end
  elseif type(names) == "string" then
    draw(buf, get_section(v.layout, names))
  else
    for _, name in ipairs(names) do
      draw(buf, get_section(v.layout, name))
    end
  end
end

function M.set_empty_lines(buf, n, w)
  local empty_lines = {}

  for _ = 1, n, 1 do
    table.insert(empty_lines, string.rep(" ", w))
  end

  vim.api.nvim_buf_set_lines(buf, 0, -1, true, empty_lines)
end

function M.mappings(val)
  for _, buf in ipairs(val.bufs) do
    vim.keymap.set("n", "<c-t>", function() end, { buffer = buf })
    vim.keymap.set("n", "q", function() utils.close(val) end, { buffer = buf })
    vim.keymap.set("n", "<esc>", function() utils.close(val) end, { buffer = buf })
  end
end

function M.run(buf, opts)
  vim.bo[buf].filetype = "UIWindow"

  if opts.custom_empty_liens then
    opts.custom_empty_liens()
  else
    M.set_empty_lines(buf, opts.h, opts.w)
  end

  -- TODO: require highlights

  M.redraw(buf, "all")

  vim.api.nvim_set_option_value("modifiable", false, { buf = buf })

  -- TODO: enable events
  -- if not vim.g.extmark_events then
  --    require events enable
  -- end
end

function M.close(buf)
  if not buf then
    vim.api.nvim_feedkeys("q", "x", false)
    return
  end

  vim.api.nvim_buf_call(buf, function()
    vim.api.nvim_feedkeys("q", "x", false)
  end)
end

return M
