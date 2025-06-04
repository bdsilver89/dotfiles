if vim.fn.executable("go") == 0 then
  return {}
end

return {
  {
    "nvim-treesitter",
    opts = { ensure_installed = { "go", "gomod", "gowork", "gosum" } },
  },

  {
    "mason.nvim",
    opts = { ensure_installed = { "gopls" } },
  },

  {
    "conform.nvim",
    dependencies = {
      "mason.nvim",
      opts = { ensure_installed = { "goimports", "gofumpt" } },
    },
    opts = {
      formatters_by_ft = {
        go = { "goimports", "gofumpt" },
      },
    },
  },

  {
    "nvim-dap",
    dependencies = {
      {
        "mason.nvim",
        opts = { ensure_installed = { "delve" } },
      },
      {
        "leoluz/nvim-dap-go",
        opts = {},
      },
    },
  },

  {
    "neotest",
    dependencies = {
      "fredrikaverpil/neotest-golang",
    },
    opts = {
      adapters = {
        ["neotest-golang"] = {
          dap_go_enabled = true,
        },
      },
    },
  },
}
