return {
  "nvim-lua/plenary.nvim",

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
