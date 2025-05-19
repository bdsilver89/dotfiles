return {
  {
    "nvim-treesitter",
    opts = { ensure_installed = { "lua", "luap", "luadoc" } },
  },

  {
    "nvim-lspconfig",
    opts = {
      servers = {
        lua_ls = {
          settings = {
            Lua = {
              runtime = {
                version = "LuaJIT",
              },
              telemetry = {
                enable = false,
              },
              diagnostics = {
                globals = { "vim", "Snacks" },
              },
              codeLens = {
                enable = true,
              },
              workspace = {
                checkThirdParty = false,
                library = {
                  [vim.fn.expand("$VIMRUNTIME/lua")] = true,
                  [vim.fn.expand("$VIMRUNTIME/lua/vim/lsp")] = true,
                  [vim.fn.stdpath("config") .. "/lua"] = true,
                  [vim.fn.stdpath("data") .. "/lazy"] = true,
                  ["${3rd}/luv/library"] = true,
                },
              },
              completion = {
                callSnippet = "Replace",
              },
              doc = {
                privateName = { "^_" },
              },
            },
          },
        },
      },
    },
  },

  {
    "conform.nvim",
    dependencies = {
      "mason.nvim",
      opts = { ensure_installed = { "stylua" } },
    },
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
      },
    },
  },
}
