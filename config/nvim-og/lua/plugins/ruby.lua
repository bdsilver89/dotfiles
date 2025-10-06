return {
  {
    "nvim-treesitter",
    opts = {
      ensure_installed = {
        "ruby",
      },
    },
  },

  {
    "mason.nvim",
    opts = { ensure_installed = { "erb-formatter", "erb-lint" } },
  },

  -- {
  --   "nvim-lspconfig",
  --   opts = {
  --     servers = {
  --       ruby_lsp = {
  --         enabled = true,
  --       },
  --       rubocop = {
  --         enabled = true,
  --       },
  --     },
  --   },
  -- },
}
