return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = { "zig" },
    },
  },

  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = {
      ensure_installed = {
        "zls",
      },
    },
  },

  {
    "nvim-neotest/neotest",
    optional = true,
    dependencies = {
      "lawrence-laz/neotest-zig",
    },
    ots = {
      adapters = {
        ["neotest-zig"] = {},
      },
    },
  },
}
