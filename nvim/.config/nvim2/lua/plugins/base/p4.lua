return {
  {
    "bdsilver89/perforce.nvim",
    cond = vim.fn.executable("p4") == 1,
    branch = "develop",
  },
}
