return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "bash" })
      end
    end,
  },
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "shfmt" })
      end
    end,
  },
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_fg = {
        sh = { "shfmt" },
      },
    },
  },
}
