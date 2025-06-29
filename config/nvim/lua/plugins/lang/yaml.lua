return {
  {
    "nvim-treesitter",
    opts = { ensure_installed = { "yaml" } },
  },

  {
    "nvim-lspconfig",
    dependencies = {
      "b0o/SchemaStore.nvim",
    },
    opts = function(_, opts)
      opts.servers.yamlls = {
        settings = {
          yaml = {
            schemas = require("schemastore").yaml.schemas(),
            validate = true,
          },
        },
      }
    end,
  },
}
