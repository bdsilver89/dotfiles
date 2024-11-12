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

function M.log(opts)
  opts = opts or {}
  opts.args = opts.args or { "log" }
  return M.open(opts)
end

function M.log_file(opts)
  local file = vim.trim(vim.api.nvim_buf_get_name(0))
  opts = opts or {}
  opts.args = { "-f", file }
  opts.cwd = vim.fn.fnamemodify(file, ":h")
  return M.open(opts)
end

return M
