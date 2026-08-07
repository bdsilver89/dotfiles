return {
  pack = {
    "https://github.com/b0o/SchemaStore.nvim",
  },

  -- jsonc has no parser of its own; the filetype maps onto `json`.
  parsers = { "json" },

  servers = {
    jsonls = {
      settings = {
        json = {
          schemas = {},
          validate = { enable = true },
        },
      },
      -- Deferred: SchemaStore is added in phase 1 but only loadable once its
      -- plugin is on rtp, which is after this table is built.
      before_init = function(_, config)
        config.settings.json.schemas = require("schemastore").json.schemas()
      end,
    },
  },

  mason = { "jsonls", "prettierd" },

  formatters_by_ft = {
    json = { "prettierd", "prettier", stop_after_first = true },
    jsonc = { "prettierd", "prettier", stop_after_first = true },
  },
}
