vim.pack.add({
  "https://github.com/nvim-mini/mini.nvim",
})

vim.schedule(function()
  require("mini.pairs").setup({})
  require("mini.surround").setup({})
  require("mini.indentscope").setup({})
end)
