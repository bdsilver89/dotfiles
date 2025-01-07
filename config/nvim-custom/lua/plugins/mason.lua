return {
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = {
      ensure_installed = {
        -- bash
        "bash-language-server",
        -- "shfmt",

        -- cmake
        -- "cmakelang",
        -- "cmakelint",
        "neocmakelsp",

        -- clangd
        -- "codelldb",

        -- json
        "json-lsp",

        -- lua
        "lua-language-server",
        "stylua",

        -- python
        "ruff",

        -- zig
        "zls",
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
