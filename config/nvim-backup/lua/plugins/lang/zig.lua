return {
  {
    "nvim-treesitter",
    opts = { ensure_installed = { "zig" } },
  },

  {
    "nvim-lspconfig",
    opts = {
      servers = {
        zls = {},
      },
    },
  },

  {
    "neotest",
    optional = true,
    dependencies = {
      "lawrence-laz/neotest-zig",
    },
    opts = {
      adapters = {
        ["neotest-zig"] = {},
      },
    },
  },
}
