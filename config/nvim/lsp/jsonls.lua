---@type vim.lsp.Config
return {
  cmd = { "vscode-json-language-server", "--stdio" },
  filetypes = { "json", "jsonc" },
  settings = {
    json = {
      valudate = { enable = true },
      schemas = require("schemastore").json.schemas(),
    },
  },
}
