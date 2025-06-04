return {
  {
    "nvim-treesitter",
    opts = { ensure_installed = { "yaml" } },
  },

  {
    "b0o/SchemaStore.nvim",
    lazy = true,
    version = false, -- last release is way too old
  },

  {
    "mason.nvim",
    opts = { ensure_installed = { "yaml-language-server" } },
  },
}
