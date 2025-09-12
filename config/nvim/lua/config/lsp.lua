vim.lsp.enable({
  "clangd",
  "lua_ls",
  "neocmake",
  "rust_analyzer",
})

vim.diagnostic.config({
  severity_sort = true,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "󰅚 ",
      [vim.diagnostic.severity.WARN] = "󰀪 ",
      [vim.diagnostic.severity.INFO] = "󰋽 ",
      [vim.diagnostic.severity.HINT] = "󰌶 ",
    },
  },
  underline = true,
  update_in_insert = false,
  -- virtual_lines = { current_line = true },
  virtual_text = {
    prefix = "󱓻",
    -- prefix = "●",
  },
})
