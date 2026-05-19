vim.pack.add({
  "https://github.com/folke/which-key.nvim",
})

local wk = require("which-key")
wk.setup({ preset = "modern" })

wk.add({
  { "<leader>b", group = "buffer" },
  { "<leader>c", group = "code" },
  { "<leader>d", group = "debug" },
  { "<leader>f", group = "file" },
  { "<leader>g", group = "git" },
  { "<leader>gh", group = "hunk" },
  { "<leader>q", group = "quit/session" },
  { "<leader>s", group = "search" },
})
