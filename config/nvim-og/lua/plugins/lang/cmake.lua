return {
  {
    "nvim-treesitter",
    opts = {
      ensure_installed = {
        "cmake",
        "make",
        "ninja",
      },
    },
  },

  {
    "nvim-lspconfig",
    opts = {
      servers = {
        neocmake = {},
      },
    },
  },
}
