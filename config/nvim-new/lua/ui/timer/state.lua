local M = {
  visible = false,
  initialized = false,
  timer = vim.uv.new_timer(),
  clock = nil,
  xpad = 3,
  progress = 0,
  mode = "focus",
  minutes = 10,
  h = 14,

  config = {
    minutes = { 25, 5 },
    on_start = nil,
    on_finish = function()
      vim.notify("Time's up!", vim.log.levels.INFO, { title = "Timer" })
    end,
    mapping = nil,
    position = "center",
  },

  status = "",
}

return M
