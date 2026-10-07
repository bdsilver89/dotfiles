
vim.diagnostic.config({
  severity_sort = true,
  virtual_text = {
    source = "if_many",
    spacing = 2,
  },
  float = {
    source = true,
  },
})


vim.lsp.enable({
  "clangd",
})
