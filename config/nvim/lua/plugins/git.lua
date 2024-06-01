return {
  -- git interface
  {
    "NeogitOrg/neogit",
    name = "Neogit",
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
}
