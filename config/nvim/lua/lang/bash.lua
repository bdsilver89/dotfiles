if vim.fn.has("win32") == 1 then
  return {}
end

return {
  {
    "nvim-treesitter",
    opts = { ensure_installed = { "bash" } },
  },

  {
    "nvim-lspconfig",
    opts = {
      servers = {
        bashls = {},
      },
    },
  },

  {
    "conform.nvim",
    dependencies = {
      "mason.nvim",
      opts = { ensure_installed = { "shfmt" } },
    },
    opts = {
      formatters_by_ft = {
        bash = { "shfmt" },
      },
    },
  },
}
