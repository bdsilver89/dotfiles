return {
  {
    "nvim-treesitter",
    opts = { ensure_installed = { "lua", "luap", "luadoc" } },
  },

  {
    "mason-tool-installer.nvim",
    opts = { ensure_installed = { "stylua" } },
  },

  {
    "nvim-lspconfig",
    opts = { 
      servers = {
        lua_ls = {
          settings = {
            Lua = {
              diagnostics = {
                globals = { "vim" },
              },
              workspace = {
                checkThirdParty = false,
              },
            },
          },
        },
      }
    },
  },

 
  {
    "conform.nvim",
    dependencies = {
    },
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
      },
    },
  },
}
