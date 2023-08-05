return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      return vim.list_extend(opts.ensure_installed, {"yaml" })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "b0o/SchemaStore.nvim",
    },
    opts = {
      servers = {
        yamlls = {
          capabilities = {
            textDocument = {
              foldingRange = {
                dynamicRegistration = false,
                lineFoldingtonly = true,
              },
            }
          },
          on_new_config = function(new_config)
            new_config.settings.yaml.schemas = new_config.settings.yaml.schemas or {}
            vim.list_extend(new_config.settings.yaml.schemas, require("schemastore").yaml.schemas())
          end,
          settings = {
            redhat = { telemetry = { enabled = false } },
            yaml = {
              keyOrdering = false,
              format = {
                enable = true,
              },
              validate = true,
              schemaStore = {
                enable = false, -- disable the builtin one and use SchemaStore.nvim
                url = "",
              },
            },
          },
        },
      },
    },
  },
}
