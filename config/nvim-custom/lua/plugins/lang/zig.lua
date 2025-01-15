if vim.fn.executable("zig") == 0 then
  return {}
end

return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = { "zig" },
    },
  },

  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "zls",
      },
    },
  },

  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        zls = {},
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
