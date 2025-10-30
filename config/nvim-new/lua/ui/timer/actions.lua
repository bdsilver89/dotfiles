local state = require("ui.timer.state")
local api = require("ui.timer.api")

return function()
  vim.keymap.set("n", "<LeftDrag>", function()
    local mouse_pos = vim.fn.getmousepos()

    vim.api.nvim_win_set_config(state.win, {
      relative = "editor",
      row = mouse_pos.screenrow - 1,
      col = mouse_pos.screencol - 1,
    })

    vim.api.nvim_win_set_config(state.input_win, {
      relative = "win",
      row = state.h + 1,
      col = -1,
    })
  end, { buffer = state.buf })

  vim.keymap.set("n", "m", api.toggle_mode, { buffer = state.buf })
  vim.keymap.set("n", "<leader>", api.toggle_status, { buffer = state.buf })
  vim.keymap.set("n", "<up>", api.increment, { buffer = state.buf })
  vim.keymap.set("n", "<down>", api.decrement, { buffer = state.buf })
  vim.keymap.set("n", "<BS>", api.reset, { buffer = state.buf })

  if state.config.mapping then
    state.config.mapping(state.buf)
  end
end
