local M = setmetatable({}, {
  __call = function(t, ...)
    return t.open(...)
  end,
})

local defaults = {
  configure = true,
  config = {},
  win = {
    -- style = "lazygit",
  },
}

function M.open(opts)
  opts = vim.tbl_deep_extend("force", defaults, opts or {})

  local cmd = { "lazygit" }
  vim.list_extend(cmd, opts.args or {})

  return require("config.utils.terminal")(cmd, opts)
end

return M
