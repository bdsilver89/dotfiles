return {
  "akinsho/toggleterm.nvim",
  cmd = { "ToggleTerm", "TermExec" },
  keys = {
    { "<leader>tv", "<cmd>ToggleTerm direction=vertical<cr>", "Terminal (vertical)" },
    { "<leader>th", "<cmd>ToggleTerm direction=horizontal<cr>", "Terminal (horizontal)" },
    { "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", "Terminal (float)" },
  },
  opts = {},
}
