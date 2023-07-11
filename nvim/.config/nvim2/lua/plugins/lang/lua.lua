if not require("config").pde.lua then
  return {}
end

return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, { "lua", "luadoc", "luap" })
    end,
  },
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, { "stylua" })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      {
        "folke/neodev.nvim",
        opts = {
          library = {
            plugins = {
            },
            types = true,
          },
        },
      },
    },
    opts = {
      servers = {
        lua_ls = {
          settings = {
            Lua = {
              workspace = {
                checkThirdParty = false,
              },
              completion = {
                callSnippet = false
              },
              telemetry = {
                enable = false,
              },
              hint = {
                enable = false,
              },
            },
          },
        },
      },
      setup = {
      },
    },
  },
}
