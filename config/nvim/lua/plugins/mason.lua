return {
  "WhoIsSethDaniel/mason-tool-installer.nvim",
  lazy = false,
  dependencies = {
    {
      "mason-org/mason.nvim",
      build = ":MasonUpdate",
      opts = {},
    },
    {
      "mason-org/mason-lspconfig.nvim",
      opts = {},
    },
  },
  opts = {
    ensure_installed = {
      "lua_ls",
      "stylua",
    },
  },
}
