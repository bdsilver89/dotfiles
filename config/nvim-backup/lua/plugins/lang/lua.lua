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
                globals = { "vim", "Snacks" },
              },
              workspace = {
                checkThirdParty = false,
                library = {
                  [vim.fn.expand("$VIMRUNTIME/lua")] = true,
                  [vim.fn.expand("$VIMRUNTIME/lua/vim/lsp")] = true,
                  [vim.fn.stdpath("config") .. "/lua"] = true,
                  [vim.fn.stdpath("data") .. "/lua"] = true,
                  ["${3rd}/luv/library"] = true,
                },
              },
            },
          },
        },
      },
    },
  },

  {
    "conform.nvim",
    dependencies = {},
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
      },
    },
  },
}
