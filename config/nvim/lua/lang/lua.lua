return {
  {
    "nvim-treesitter",
    opts = { ensure_installed = { "lua", "luap", "luadoc" } },
  },

  {
    "mason.nvim",
    opts = { ensure_installed = { "lua-language-server" } },
  },

  {
    "conform.nvim",
    dependencies = {
      "mason.nvim",
      opts = { ensure_installed = { "stylua" } },
    },
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
      },
    },
  },
}
