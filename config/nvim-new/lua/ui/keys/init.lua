local M = {}

local state = require("ui.keys.state")
local ui = require("utils.ui")
local utils = require("ui.keys.utils")

state.ns = vim.api.nvim_create_namespace("keys")

function M.open()
  state.visibile = true
  state.buf = vim.api.nvim_create_buf(false, true)
  utils.gen_winconfig()
  vim.bo[state.buf].ft = "keys"

  state.timer = vim.uv.new_timer()
  state.on_key = vim.on_key(function(_, char)
    if not state.win then
      state.win = vim.api.nvim_open_win(state.buf, false, state.config.winopts)
      vim.api.nvim_set_option_value("winhl", state.config.winhl, { win = state.win })
    end

    utils.parse_key(char)

    state.timer:stop()
    state.timer:start(state.config.timeout * 1000, 0, vim.schedule_wrap(utils.clear_and_close))
  end)

  vim.api.nvim_set_hl(0, "keysinactive", { default = true, link = "Visual" })
  vim.api.nvim_set_hl(0, "keysactive", { default = true, link = "pmenusel" })

  local group = vim.api.nvim_create_augroup("keys", { clear = true })

  vim.api.nvim_create_autocmd("VimResized", {
    group = group,
    callback = function()
      if state.win then
        utils.redraw()
      end
    end,
  })

  vim.api.nvim_create_autocmd("TabEnter", {
    group = group,
    callback = function()
      if state.win then
        M.close()
        M.open()
      end
    end,
  })

  vim.api.nvim_create_autocmd("WinClosed", {
    group = group,
    buffer = state.buf,
    callback = function()
      if state.win then
        M.close()
        M.open()
      end
    end,
  })
end

function M.close()
  vim.api.nvim_del_augroup_by_name("keys")
  state.timer:stop()
  state.keys = {}
  state.w = 1
  state.extmark_id = nil
  vim.cmd("silent! bd" .. state.buf)
  vim.on_key(nil, state.on_key)
  state.visibile = false
  state.win = nil
end

function M.toggle()
  M[state.visibile and "close" or "open"]()
end

return M
