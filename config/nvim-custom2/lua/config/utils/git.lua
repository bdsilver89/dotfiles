local M = {}

local defaults = {
  win = {
    -- style = "lazygit",
  },
}

function M.get_root(path)
  path = path or 0
  path = type(path) == "number" and vim.api.nvim_buf_get_name(path) or path
  path = vim.fs.normalize(path)
  local git_root = vim.fs.find(".git", { path = path, upward = true })[1]
  return git_root and vim.fn.fnamemodify(git_root, ":h") or nil
end

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
  local root = M.get_root()
  local cmd = { "git", "-C", root, "log", "-n", opts.count, "-u", "-L", line .. ",+1:" .. file }
  return require("config.utils.terminal")(cmd, opts)
end

return M
