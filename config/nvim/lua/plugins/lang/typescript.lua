return {
  {
    "nvim-treesitter",
    opts = { ensure_installed = { "javascript", "jsdoc", "tsx", "typescript" } },
  },

  {
    "nvim-lspconfig",
    opts = { servers = { vtsls = {} } },
  },
}