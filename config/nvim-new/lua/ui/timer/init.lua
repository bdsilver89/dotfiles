local M = {}

local api = require("ui.timer.api")
local state = require("ui.timer.state")
local utils = require("ui.timer.utils")
local ui = require("utils.ui")

state.ns = vim.api.nvim_create_namespace("timer")

function M.open()
  state.initialized = true
  state.minutes = state.config.minutes[1]

  utils.secs_to_ascii(state.minutes * 60)

  state.w = 24 + 2 + (2 * 4) + (2 * state.xpad)
  state.w_with_pad = state.w - (2 * state.xpad)

  utils.openwins()

  vim.fn.prompt_setcallback(state.input_buf, function(input)
    local n = tonumber(input)
    if type(n) == "number" then
      state.minutes = n
      api.reset()
    end
  end)

  ui.gen_data({
    {
      buf = state.buf,
      layout = require("ui.timer.layout"),
      xpad = state.xpad,
      ns = state.ns,
    },
  })

  ui.run(state.buf, { h = state.h, w = state.w })
  -- volt_events.add(state.buf)

  ui.mappings({
    bufs = { state.buf, state.input_buf },
    after_close = function()
      state.timer:stop()
      state.buf = nil
      state.input_buf = nil
      state.volt_set = false
      vim.api.nvim_del_augroup_by_name("TimerResize")
    end,
  })

  require("ui.timer.actions")()

  vim.api.nvim_create_autocmd("VimResized", {
    group = vim.api.nvim_create_augroup("TimerResize", {}),
    callback = function()
      if state.visible then
        require("ui.timer").toggle()
        require("ui.timer").toggle()
      end
    end,
  })
end

function M.toggle()
  if not state.initialized then
    M.open()
  elseif state.visible then
    vim.api.nvim_win_close(state.win, true)
    vim.api.nvim_win_close(state.input_win, true)
  else
    utils.openwins()
  end

  state.visible = not state.visible
end

return M
