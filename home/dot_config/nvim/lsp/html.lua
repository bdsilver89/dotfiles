---@type vim.lsp.Config
return {
  cmd = { "vscode-html-language-server", "--stdio" },
  filetypes = { "html" },
  emabeddLanguages = { css = true, javascript = true },
}
