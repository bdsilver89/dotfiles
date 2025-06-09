return {
  cmd = { "vscode-json-language-server", "--stdio" },
  filetypes = { "json", "jsonc" },
  init_options = {
    provideFormatter = true,
  },
  settings = {
    json = {
      format = {
        enable = true,
      },
      schemas = require("schemastore").json.schemas(),
      validate = { enable = true },
    },
  },
}
