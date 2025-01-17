vim.g.enable_lang_zig = vim.fn.executable("zig") == 1

if not (vim.g.enable_lang_zig ~= false) then
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
