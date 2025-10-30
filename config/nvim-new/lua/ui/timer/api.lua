local M = {}

local state = require("ui.timer.state")
local utils = require("ui.timer.utils")
local redraw = require("utils.ui").redraw

function M.start()
  if state.config.on_start then
    state.config.on_start()
  end

  local mins = state.status == "pause" and (state.totla_secs / 60) or state.minutes
  utils.start(mins)
  state.status = "start"
end

function M.reset()
  state.progress = 0
  state.status = ""
  state.timer:stop()
  utils.secs_to_ascii(state.minutes * 60)
  redraw(state.buf, "clock")
  redraw(state.buf, "progress")
  redraw(state.buf, "action_buttons")
end

function M.pause()
  state.status = "pause"
  state.timer:stop()
end

function M.increment()
  state.minutes = state.minutes + 1
  M.reset()
end

function M.decrement()
  if state.minutes == 0 then
    return
  end

  state.minutes = state.minutes - 1
  M.reset()
end

function M.toggle_mode()
  local focusmode = state.mode == "focus"
  state.mode = (focusmode and "break") or "focus"
  state.minutes = state.config.minutes[focusmode and 2 or 1]
  redraw(state.buf, "modes")
  M.reset()
end

function M.toggle_status()
  M[state.status == "start" and "pause" or "start"]()
  redraw(state.buf, "action_buttons")
end

return M
