return {
  -- git interface
  {
    "NeogitOrg/neogit",
    name = "Neogit",
    enabled = true,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",
      "nvim-telescope/telescope.nvim",
    },
    cmd = "Neogit",
    keys = {
      { "<leader>gm", "<cmd>Neogit<cr>", desc = "Status" },
      { "<leader>gl", "<cmd>Neogit pull<cr>", desc = "Pull" },
      { "<leader>gp", "<cmd>Neogit push<cr>", desc = "Push" },
    },
    opts = {},
  },

  {
    "tpope/vim-fugitive",
    lazy = false,
  },

  {
    "SuperBo/fugit2.nvim",
    enabled = false,
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons",
      "nvim-lua/plenary.nvim",
      {
        "chrisgrieser/nvim-tinygit", -- optional: for Github PR view
        dependencies = { "stevearc/dressing.nvim" },
      },
    },
    cmd = { "Fugit2", "Fugit2Blame", "Fugit2Diff", "Fugit2Graph" },
    keys = {
      { "<leader>gm", mode = "n", "<cmd>Fugit2<cr>" },
    },
    opts = {
      width = 70,
    },
  },
}
