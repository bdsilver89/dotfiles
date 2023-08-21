return {
  {
    "bdsilver89/perforce.nvim",
    enabled = vim.fn.executable("p4") == 1,
    event = { "BufReadPost", "BufNewFile" },
    config = true,
  }
}
