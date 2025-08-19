vim.lsp.enable({
  "clangd",
  "lua_ls",
})

vim.diagnostic.config({
  severity_sort = true,
  -- signs = true,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "󰅚 ",
      [vim.diagnostic.severity.WARN] = "󰀪 ",
      [vim.diagnostic.severity.INFO] = "󰋽 ",
      [vim.diagnostic.severity.HINT] = "󰌶 ",
    },
    numhl = {
      [vim.diagnostic.severity.ERROR] = "ErrorMsg",
      [vim.diagnostic.severity.WARN] = "WarningMsg",
    },
  },
  underline = true,
  update_in_insert = false,
  virtual_lines = { current_line = true },
  virtual_text = false,
})

vim.keymap.set("n", "<leader>ud", function()
  local state = vim.diagnostic.is_enabled()
  vim.diagnostic.enable(not state)
  if vim.diagnostic.is_enabled() then
    vim.notify("***Enabled diagnostics***", vim.log.levels.INFO)
  else
    vim.notify("***Disabled diagnostics***", vim.log.levels.WARN)
  end
end, { desc = "Toggle diagnostics" })
