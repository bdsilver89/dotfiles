vim.pack.add({
  "https://github.com/nvim-lualine/lualine.nvim",
})

require("lualine").setup({
  options = {
    component_separators = "",
    section_separators = "",
  },
  extensions = { "quickfix", "oil" },
})
