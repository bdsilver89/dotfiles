local has_schemastore, schemastore = pcall(require, "schemastore")

return {
  cmd = { "yaml-language-server", "--stdio" },
  filetypes = { "yaml", "yaml.docker-compose", "yaml.gitlab", "yaml.helm-values" },
  -- root_markers = { ".git" },
  capabilities = {
    textDocument = {
      foldingRange = {
        dynamicRegistration = false,
        lineFoldingOnly = true,
      },
    },
  },
  settings = {
    redhat = { telemetry = { enabled = false } },
    yaml = {
      keyOrdering = false,
      format = {
        enable = true,
      },
      schemas = has_schemastore and schemastore.yaml.schemas(),
      schemaStore = {
        enable = false,
        url = "",
      },
      validate = true,
    },
  },
}
