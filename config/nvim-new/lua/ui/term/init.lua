local M = {}

local ui = require("utils.ui")

local state = {
  ns = vim.api.nvim_create_namespace("term"),
  terminals = nil,
  bar_redraw_timeout = 10000,
  prev_win_focussed = 0,
  config = {
    border = false,
    size = { h = 60, w = 70 },
    position = nil,
    mappings = { sidebar = nil, term = nil },
    terminals = {
      { name = "Terminal" },
    },
  },
}

function M.open()
  local 

  ui.gen_data({
    {
      buf = state.sidebuf,
      ns = state.ns,
      layout = {},
      xpad = 1,
    },
    {
      buf = state.barbuf,
      ns = state.ns,
      layout = {},
      xpad = 1,
    },
  })

  vim.api.nvim_set_option_value("modifiable", true, { buf = state.sidebar })
  vim.api.nvim_set_option_value("modifiable", true, { buf = state.barbuf })

  ui.run(state.sidebuf, { h = sidebar_win_opts.height, w = sidebar_win_opts.width })
  ui.run(state.barbuf, { h = 1, w = bar_win_opts.width })

  state.win = vim.api.nvim_open_win(state.buf, true, state.term_win_opts)

  -- termwin hl
  -- switch buf
  ui.redraw(state.barbuf, "bar")

  -- mappings
  -- hl
  -- redraw timer
  -- autocmds
end

-- function M.toggle()
-- end

return M
