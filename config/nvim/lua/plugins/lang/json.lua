return {
  {
    "nvim-treesitter",
    opts = { ensure_installed = { "json", "json5" } }, --jsonc
  },

  {
    "b0o/SchemaStore.nvim",
    lazy = true,
    version = false, -- last release is way too old
  },

  {
    "mason.nvim",
    opts = { ensure_installed = { "json-lsp" } }, --jsonc
  },
}
