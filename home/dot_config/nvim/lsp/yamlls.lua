---@type vim.lsp.Config
return {
  cmd = { "yaml-language-server", "--stdio" },
  filetypes = { "yaml" },
  settings = {
    schemastore = { enable = false, url = "" },
    schemas = require("schemastore").yaml.schemas(),
  },
}
