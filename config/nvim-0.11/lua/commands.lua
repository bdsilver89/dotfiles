vim.api.nvim_create_user_command("ToggleFormat", function()
  local state = not vim.g.autoformat
  vim.g.autoformat = state
  vim.notify(
    string.format("***%s auto-formatting***", state and "Enabled" or "Disabled"),
    state and vim.log.levels.INFO or vim.log.levels.WARN
  )
end, { desc = "Toggle conform.nvim auto-formatting", nargs = 0 })

vim.api.nvim_create_user_command("LspRestart", function()
  vim.lsp.stop_client(vim.lsp.get_clients())
  vim.cmd("edit")
end, { desc = "LSP restart", nargs = 0 })

vim.api.nvim_create_user_command("LspStop", function()
  vim.lsp.stop_client(vim.lsp.get_clients())
end, { desc = "LSP stop", nargs = 0 })
