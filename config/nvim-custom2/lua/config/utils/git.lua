local M = {}

local defaults = {
  win = {
    -- style = "lazygit",
  },
}

function M.blame_line(opts)
  opts = vim.tbl_deep_extend("force", {
    count = 5,
    interactice = false,
    win = {
      -- style= "blame_line"
    },
  }, opts or {})

  local cursor = vim.api.nvim_win_get_cursor(0)
  local line = cursor[1]
  local file = vim.api.nvim_buf_get_name(0)
  local cmd = { "git", "log", "-n", opts.count, "-u", "-L", line .. ",+1:" .. file }
  return require("config.utils.terminal")(cmd, opts)
end

return M
