return {
  -- treesitter changes
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "doxygen",
        "make",
        "meson",
        "starlark",
        "sql",
        "xml",
      },
    },
  },
}
