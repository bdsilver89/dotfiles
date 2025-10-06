return {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },

  {
    "tpope/vim-sleuth",
    lazy = false,
  },

  {
    "stevearc/oil.nvim",
    keys = {
      { "-", "<cmd>Oil<cr>", desc = "Oil file explorer" },
    },
    opts = {},
  },
}
