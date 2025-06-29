if vim.fn.has("win32") == 1 then
  return {}
end

return {
  {
    "nvim-treesitter",
    opts = { ensure_installed = { "bash" } },
  },

  {
    "mason-tool-installer.nvim",
    opts = { ensure_installed = { "shfmt", "shellcheck" } },
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
    opts = {
      formatters_by_ft = {
        sh = { "shfmt", "shellcheck" },
        bash = { "shfmt", "shellcheck" },
        zsh = { "shfmt", "shellcheck" },
      },
    },
  },

  {
    "nvim-lint",
    opts = {
      linters_by_ft = {
        sh = { "shellcheck" },
        bash = { "shellcheck" },
        zsh = { "shellcheck" },
      },
    },
  },
}
