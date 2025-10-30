local M = {}

local state = require("utils.ui.state")

function M.close(val)
  for _, buf in ipairs(val) do
    local valid = vim.api.nvim_buf_is_valid(buf)
    if valid then
      vim.api.nvim_buf_delete(buf, { force = true })
      state[buf] = nil
    end

    -- TODO: more actions and events
  end
end

return M
