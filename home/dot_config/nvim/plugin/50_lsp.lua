local now_if_args = Config.now_if_args


now_if_args(function()
  vim.lsp.enable({
    "clangd",
  })
end)
