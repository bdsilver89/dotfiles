return {
  pack = {
    "https://github.com/b0o/SchemaStore.nvim",
  },

  parsers = { "yaml" },

  servers = {
    yamlls = {
      settings = {
        yaml = {
          schemaStore = { enable = false, url = "" },
          schemas = {},
        },
      },
      before_init = function(_, config)
        config.settings.yaml.schemas = require("schemastore").yaml.schemas()
      end,
    },
  },

  mason = { "yamlls", "prettierd" },

  formatters_by_ft = {
    yaml = { "prettierd", "prettier", stop_after_first = true },
  },
}
