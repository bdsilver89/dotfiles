return {
  "stevearc/oil.nvim",
  lazy = vim.fn.argc(-1) == 0,
  cmd = "Oil",
  keys = {
    { "-", "<cmd>Oil<cr>", desc = "File Explorer (Oil)" },
  },
  opts = {
    default_file_explorer = true,
  },
}
