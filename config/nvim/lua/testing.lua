vim.pack.add({
  "https://github.com/nvim-neotest/neotest",
  "https://github.com/nvim-neotest/nvim-nio",
})

require("neotest").setup({
  adapters = {},
})
