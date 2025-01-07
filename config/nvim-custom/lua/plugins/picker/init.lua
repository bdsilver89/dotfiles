return {
  {
    import = "plugins.picker.telescope",
    enabled = vim.g.picker == "telescope",
  },
  {
    import = "plugins.picker.fzf",
    enabled = vim.g.picker == "fzf",
  },
}
