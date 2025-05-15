vim.api.nvim_create_user_command("LspRestart", function()
  vim.lsp.stop_client(vim.lsp.get_clients())
  vim.cmd("edit")
end, { desc = "LSP restart", nargs = 0 })

vim.api.nvim_create_user_command("LspStop", function()
  vim.lsp.stop_client(vim.lsp.get_clients())
end, { desc = "LSP stop", nargs = 0 })
