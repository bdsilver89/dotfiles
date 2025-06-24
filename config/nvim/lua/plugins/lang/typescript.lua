return {
  {
    "nvim-treesitter",
    opts = { ensure_installed = { "javascript", "jsdoc", "tsx", "typescript" } },
  },

  {
    "mason.nvim",
    opts = { ensure_installed = { "vtsls" } },
  },
}
