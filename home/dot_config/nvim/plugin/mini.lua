vim.pack.add({
  "https://github.com/nvim-mini/mini.nvim",
})

require("mini.icons").setup({})
MiniIcons.mock_nvim_web_devicons()

vim.schedule(function()
  MiniIcons.tweak_lsp_kind()

  require("mini.pairs").setup({})
  require("mini.surround").setup({})
  require("mini.indentscope").setup({})
end)
