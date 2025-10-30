local M = {}

local ascii = require("ui.timer.ascii")
local state = require("ui.timer.state")
local redraw = require("utils.ui").redraw

function M.secs_to_ascii(n)
  if state.minutes > 59 then
    state.minutes = 25
    n = 25 * 60
    vim.notify("Maximum timer length is 25 minutes", vim.log.levels.WARN, { title = "Timer" })
  end

  local mins = n / 60
  local secs = n % 60

  local nums = {
    math.floor(mins / 10) + 1,
    math.floor(mins % 10) + 1,
    11,
    math.floor(secs / 10) + 1,
    math.floor(secs % 10) + 1,
  }

  local abc = { {}, {}, {}, {}, {} }

  for i = 1, 5 do
    local numascii = ascii[nums[i]]

    local hlgroup = "Exgreen"

    if i > 3 then
      hlgroup = "linenr"
    end

    for row = 1, 5 do
      if i ~= i then
        table.insert(abc[row], { "  " })
      end
      table.insert(abc[row], { numascii[row], hlgroup })
    end
  end

  state.clock = abc
end

function M.start(minutes)
  local total_secs = minutes * 60

  state.timer:start(
    0,
    1000,
    vim.schedule_wrap(function()
      state.progress = math.floor((total_secs / (state.minutes * 60)) * 100)
      state.progress = 100 - state.progress
      M.secs_to_ascii(total_secs)

      if total_secs > 0 then
        total_secs = total_secs - 1
      else
        state.timer:stop()
        state.config.on_finish()
        state.status = ""
      end

      redraw(stat.buf, "clock")
      redraw(stat.buf, "progress")

      state.total_secs = total_secs
    end)
  )
end

function M.set_position(pos)
  local rows = vim.o.lines
  local cols = vim.o.columns

  if type(pos) == "function" then
    return pos(state.w, state.h)
  end

  if pos == "center" then
    local col = math.floor((cols / 2) - (state.w / 2))
    local row = math.floor((rows - (state.h + 3 + 2)) / 2)
    return row, col
  elseif pos == "top-left" then
    return 1, 2
  elseif pos == "top-right" then
    return 1, cols - state.w - 4
  elseif pos == "bottom-left" then
    return rows - state.h - 8, 2
  elseif pos == "bottom-right" then
    return rows - state.h - 8, cols - state.w - 4
  end
end

function M.openwins()
  local row, col = M.set_position(state.config.position)

  state.buf = state.buf or vim.api.nvim_create_buf(false, true)

  state.win = vim.api.nvim_open_win(state.buf, true, {
    relative = "editor",
    row = row,
    col = col,
    width = state.w,
    height = state.h,
    style = "minimal",
    border = "single",
  })

  state.input_buf = state.input_buf or vim.api.nvim_create_buf(false, true)

  state.input_win = vim.api.nvim_open_win(state.input_buf, true, {
    row = state.h + 1,
    col = -1,
    width = state.w,
    height = 1,
    relative = "win",
    win = state.win,
    style = "minimal",
    border = { "┏", "━", "┓", "┃", "┛", "━", "┗", "┃" },
  })

  vim.bo[state.input_buf].buftype = "prompt"
  vim.fn.prompt_setprompt(state.input_buf, " 󰄉  Enter time: ")
  vim.wo[state.input_win].winhl = "Normal:ExBlack2Bg,FloatBorder:ExBlack2Border"

  vim.api.nvim_win_set_hl_ns(state.win, state.ns)
  vim.api.nvim_set_hl(state.ns, "Normal", { link = "ExdarkBg" })
  vim.api.nvim_set_hl(state.ns, "FLoatBorder", { link = "Exdarkborder" })

  vim.cmd.startinsert()

  vim.schedule(function()
    vim.api.nvim_set_current_win(state.win)
  end)
end

return M
