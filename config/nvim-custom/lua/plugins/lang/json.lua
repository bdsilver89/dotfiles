return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "json5" } },
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
        jsonls = {
          on_new_config = function(new_config)
            new_config.settings.json.schemas = vim.tbl_deep_extend(
              "force",
              new_config.settings.json.schemas or {},
              require("schemastore").json.schemas()
            )
          end,
          settings = {
            json = {
              format = {
                enable = true,
              },
              validate = {
                enable = true,
              },
            },
          },
        },
      },
    },
  },
}
