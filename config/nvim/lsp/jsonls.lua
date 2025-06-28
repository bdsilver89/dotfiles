local has_schemastore, schemastore = pcall(require, "schemastore")

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
      schemas = has_schemastore and schemastore.json.schemas(),
      validate = { enable = true },
    },
  },
}
