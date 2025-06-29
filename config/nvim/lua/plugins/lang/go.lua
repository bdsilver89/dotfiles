if vim.fn.executable("go") == 0 then
  return {}
end

return {
  {
    "nvim-treesitter",
    opts = { ensure_installed = { "go", "gomod", "gowork", "gosum" } },
  },

  {
    "nvim-lspconfig",
    opts = { servers = { gopls = {} } },
  },

  {
    "mason-tool-installer.nvim",
    opts = { ensure_installed = { "goimports", "gofumpt", "delve" } },
  },

  {
    "conform.nvim",
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