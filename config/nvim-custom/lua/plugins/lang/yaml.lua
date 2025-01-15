return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = { "yaml" },
    },
  },

  {
    "b0o/SchemaStore.nvim",
    lazy = true,
    version = false,
  },
}
