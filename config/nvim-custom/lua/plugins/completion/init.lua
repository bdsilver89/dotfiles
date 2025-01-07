return {
  {
    import = "plugins.completion.blink",
    enabled = vim.g.completion_engine == "blink.cmp",
  },
  {
    import = "plugins.completion.nvim-cmp",
    enabled = vim.g.completion_engine == "nvim-cmp",
  },
}
