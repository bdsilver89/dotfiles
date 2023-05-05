return {
  {
    "SmiteshP/nvim-navbuddy",
    event = "VeryLazy",
    cmd = "Navbuddy",
    dependencies = {
      "neovim/nvim-lspconfig",
      "SmiteshP/nvim-navic",
      "MunifTanjim/nui.nvim",
      "numToStr/Comment.nvim",
      "nvim-telescope/telescope.nvim",
    },
    opts = {
      lsp = {
        auto_attach = true,
      },
    },
    keys = {
      { "<leader>cn", "<cmd>Navbuddy<cr>", desc = "Navbuddy" }
    },
  },
  {
    "simrat39/symbols-outline.nvim",
    event = "VeryLazy",
    cmd = "SymbolsOutline",
    keys = {
      { "<leader>cs", "<cmd>SymbolsOutline<cr>", desc = "Symbols outline" }
    },
  },
}
