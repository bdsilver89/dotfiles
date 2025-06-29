return {
  {
    "nvim-treesitter",
    opts = { ensure_installed = { "json", "json5" } }, --jsonc
  },

  {
    "nvim-lspconfig",
    dependencies = {
      "b0o/SchemaStore.nvim",
    },
    opts = function(_, opts)
      opts.servers.jsonls = {
        settings = {
          json = {
            schemas = require("schemastore").json.schemas(),
            validate = { enable = true },
          },
        },
      }
    end,
  },
}
