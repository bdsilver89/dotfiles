return {
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    enabled = not vim.g.prefer_git,
    cmd = {
      "MasonToolsInstall",
      "MasonToolsInstallSync",
      "MasonToolsUpdate",
      "MasonToolsUpdateSync",
      "MasonToolsClean",
    },
    dependencies = {
      {
        "williamboman/mason.nvim",
        enabled = not vim.g.prefer_git,
        cmd = {
          "Mason",
          "MasonInstall",
          "MasonUninstall",
          "MasonUninstallAll",
          "MasonLog",
        },
        keys = {
          { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" },
        },
        opts = {
          ensure_installed = {},
          -- ui = {
          --   border = "rounded",
          -- },
        },
      },
      {
        "williamboman/mason-lspconfig.nvim",
        enabled = not vim.g.prefer_git,
        opts = {},
      },
      -- {
      --   "jay-babu/mason-nvim-dap.nvim",
      --   enabled = not vim.g.prefer_git,
      --   opts = {},
      -- },
    },
    opts = {
      -- HACK: temporary until nvim-dap is configured
      integrations = {
        ['mason-nvim-dap'] = false,
      },
      ensure_installed = {
        -- lua
        "lua-language-server", "stylua", "selene",
      },
    },
  }
}
