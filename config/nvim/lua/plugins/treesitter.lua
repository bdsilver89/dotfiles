return {
  -- treesitter changes
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      -- prefer git-only clones for improved connectivity
      require("nvim-treesitter.install").prefer_git = true

      vim.list_extend(opts.ensure_installed, {
        "doxygen",
        "ini",
        "make",
        "meson",
        "starlark",
        "sql",
        "xml",
      })

      return opts
    end,
  },
}
