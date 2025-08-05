return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "toml" } },
  },

  {
    "nvim-lspconfig",
    opts = { servers = { taplo = {} } },
  },
}
