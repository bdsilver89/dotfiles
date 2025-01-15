return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "mason.nvim",
      "mason-tool-installer.nvim",
    },
    event = { "BufReadPost", "BufNewFile" },
    config = function(_, _)
      require("plugins.lsp.on_attach").setup()
      require("plugins.lsp.diagnostics").setup()
      require("plugins.lsp.servers").setup()
    end,
  },

  {
    "williamboman/mason-lspconfig.nvim",
    lazy = true,
    opts = {},
  },
}
