local M = {}

local api = require("ui.timer.api")
local state = require("ui.timer.state")

function M.modes()
  local hovermark = vim.g.hovered
  local mode = state.mode

  local focus_m = {
    "   Focus ",
    ((mode == "focus" or hovermark == "focus_m") and "exgreen") or "commentfg",
    {
      hover = { id = "focus_m", redraw = "modes" },
      click = api.toggle_mode,
    },
  }

  local break_m = {
    " 󰒲  Break",
    ((mode == "break" or hovermark == "break_m") and "exgreen") or "commentfg",
    {

      hover = { id = "break_m", redraw = "modes" },
      click = api.toggle_mode,
    },
  }

  return {
    { { "│ ", "commentfg" }, { "󰀘  Modes     " }, focus_m, break_m, { " │", "commentfg" } },
  }
end

function M.clock()
  return state.clock
end

function M.progress()
  local lines = require("utils.ui.components").progress_bar({
    w = state.w_with_pad,
    val = state.progress,
    icon = { on = "|", off = "|" },
  })

  return { lines }
end

function M.action_buttons()
  local hovermark = vim.g.nvmark_hovered

  local btn1 = {
    state.status == "start" and "  Pause" or "  Start",
    hovermark == "tbtn1" and "ExRed" or "Normal",

    {
      hover = { id = "tbtn1", redraw = "actionbtns" },
      click = api.toggle_status,
    },
  }

  local resetbtn = {
    "  Reset ",
    hovermark == "tbtn2" and "normal" or "Exblue",
    {

      hover = { id = "tbtn2", redraw = "actionbtns" },
      click = api.reset,
    },
  }

  local pad = { string.rep(" ", 7) }

  local plusbtn = {
    "",
    hovermark == "tbtn3" and "normal" or "exgreen",
    {
      hover = { id = "tbtn3", redraw = "actionbtns" },
      click = api.increment,
    },
  }

  local minbtn = {
    "",
    hovermark == "tbtn4" and "normal" or "exred",
    {
      hover = { id = "tbtn4", redraw = "actionbtns" },
      click = api.decrement,
    },
  }

  return {
    { btn1, pad, minbtn, { "  " }, plusbtn, pad, resetbtn },
  }
end

return M
