return {
  {
    import = "plugins.core.completion.blink",
    enabled = vim.g.completion_engine == "blink.cmp",
  },
  {
    import = "plugins.core.completion.nvim-cmp",
    enabled = vim.g.completion_engine == "nvim-cmp",
  },
  {
    import = "plugins.core.completion.mini",
    enabled = vim.g.completion_engine == "mini",
  },
}
