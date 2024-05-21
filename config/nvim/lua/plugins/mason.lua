return {
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    enabled = vim.g.enable_mason_packages,
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
        enabled = vim.g.enable_mason_packages,
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
        },
      },
      {
        "williamboman/mason-lspconfig.nvim",
        enabled = vim.g.enable_mason_packages,
        opts = {},
      },
      {
        "jay-babu/mason-nvim-dap.nvim",
        enabled = vim.g.enable_mason_packages,
        opts = {},
      },
    },
    opts = {
      ensure_installed = {},
    },
  },
}
