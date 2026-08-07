return {
  parsers = { "lua", "luadoc" },

  servers = {
    lua_ls = {
      settings = {
        Lua = {
          workspace = {
            library = { vim.env.VIMRUNTIME },
          },
          diagnostics = {
            globals = { "vim" },
          },
        },
      },
    },
  },

  mason = {
    "lua_ls",
    "stylua",
  },

  formatters_by_ft = {
    lua = { "stylua" },
  },
}
