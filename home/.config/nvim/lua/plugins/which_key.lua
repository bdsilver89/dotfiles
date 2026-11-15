require("which-key").setup({
  spec = {
    {
      mode = { "n", "x" },
      { "<leader>b", group = "buffers" },
      { "<leader>g", group = "git" },
      { "<leader>u", group = "ui" },
      { "<leader>x", group = "diagnostics" },
    },
  },
})
