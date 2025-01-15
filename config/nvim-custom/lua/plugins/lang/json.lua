return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = { "json", "jsonc", "json5" },
    },
  },

  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = {
      ensure_installed = { "json-lsp" },
    },
  },

  {
    "b0o/SchemaStore.nvim",
    lazy = true,
    version = false,
  },
}
