return {
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = {
      ensure_installed = {
        -- bash
        "bash-language-server",
        "shfmt",

        -- cmake
        "cmakelang",
        "cmakelint",
        "neocmakelsp",

        -- clangd
        "codelldb",

        -- lua
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
