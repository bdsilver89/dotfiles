---@type vim.lsp.Config
return {
  cmd = { "clangd", "--background-index" },
  filetypes = { "c", "cpp" },
  root_markers = { ".clangd", "compile_commands.json" },
}
