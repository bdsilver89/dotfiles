return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    lazy = false,
    enabled = false,
    -- init = function()
    --   vim.cmd.colorscheme("catppuccin")
    -- end,
  },
  {
    "rose-pine/neovim",
    name = "rose-pine",
    priority = 1000,
    lazy = false,
    enabled = true,
    init = function()
      vim.cmd.colorscheme("rose-pine")
    end,
  },
}
