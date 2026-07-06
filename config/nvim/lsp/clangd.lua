---@type vim.lsp.Config
return {
  cmd = {
    "clangd",
    "--backgrond-index",
    "-j=2",
  },
  filetypes = { "c", "cpp" },
  root_markers = { ".clangd", ".git" },
}
