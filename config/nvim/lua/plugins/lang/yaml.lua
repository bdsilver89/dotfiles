return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "yaml" })
      end
    end,
  },
  {
    "b0o/SchemaStore.nvim",
    lazy = true,
    version = false,
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        yamlls = {
          capabilities = {
            textDocument = {
              fodlingRange = {
                dynamicRegistration = false,
                lindFoldingOnly = true,
              },
            },
          },
          on_new_config = function(new_config)
            new_config.settings.yaml.schemas = vim.tbl_deep_extend(
              "force",
              new_config.settings.yaml.schemas or {},
              require("schemastore").yaml.schemas()
            )
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
                -- disable builtin schemastore, use schemastore.nvim override
                enable = false,
                url = "",
              },
            },
          },
        },
      },
      setup = {
        yamlls = function()
          -- neovim < 0.10 does not have dynamic registration for formatting
          if vim.fn.has("nvim-0.10") == 0 then
            vim.api.nvim_create_autocmd("LspAttach", {
              callback = function(event)
                local buffer = event.buf
                local client = vim.lsp.get_client_by_id(event.data.client_id)
                if client.name == "yamlls" then
                  client.server_capabilities.documentFormattingProvider = true
                end
              end,
            })
          end
        end,
      },
    },
  },
}
