return {
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    cmd = {
      "MasonToolsInstall",
      "MasonToolsInstallSync",
      "MasonToolsUpdate",
      "MasonToolsUpdateSync",
      "MasonToolsClean",
    },
    opts_extend = { "ensure_installed" },
    opts = {
      ensure_installed = {
        "lua-language-server",
        "stylua",
      },
    },
  },

  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    keys = {
      { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" },
    },
    lazy = true,
    opts = {
      ui = {
        border = "rounded",
      },
    },
  },
}
