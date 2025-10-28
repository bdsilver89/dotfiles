return {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 1000,
  lazy = false,
  opts = {},
  init = function()
    vim.cmd.colorscheme("catppuccin")
  end,
}
