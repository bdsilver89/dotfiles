return {
  {
    import = "plugins.picker.telescope",
    enabled = vim.g.picker == "telescope",
  },
  {
    import = "plugins.picker.fzf",
    enabled = vim.g.picker == "fzf",
  },
  -- {
  --   import = "plugins.picker.snacks",
  --   enabled = vim.g.picker == "snacks",
  -- },
}
