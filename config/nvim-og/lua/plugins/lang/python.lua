return {
  {
    "nvim-treesitter",
    opts = {
      ensure_installed = {
        "python",
      },
    },
  },

  {
    "nvim-lspconfig",
    opts = {
      servers = {
        pyright = {},
        ruff = {},
      },
    },
  },
}
