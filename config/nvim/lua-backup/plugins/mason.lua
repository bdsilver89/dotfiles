vim.pack.add({
  "https://github.com/mason-org/mason.nvim",
  "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim",
  "https://github.com/mason-org/mason-lspconfig.nvim",
})

require("mason").setup()
require("mason-tool-installer").setup({
  ensure_installed = {
    "lua_ls",
    "stylua",
    "pyright",
    "basedpyright",
    "bashls",
    "jdtls",
  },
})
