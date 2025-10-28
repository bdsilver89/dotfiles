return {
  "mason-org/mason-lspconfig.nvim",
  event = { "BufReadPost", "BufNewFile" },
  dependencies = {
    {
      "mason-org/mason.nvim",
      cmd = {
        "Mason",
        "MasonInstall",
        "MasonUpdate",
        "MasonUninstall",
        "MasonUninstallAll",
      },
      keys = {
        { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" },
      },
      opts = {
        check_outdated_packages_on_open = false,
        icons = {
          package_pending = " ",
          package_installed = " ",
          package_uninstalled = " ",
        },
      },
    },
    "nvim-lspconfig",
  },
  opts = {
    ensure_installed = {
      "stylua",
      "lua_ls",
      "jdtls",
    },
  },
  config = function(_, opts)
    local mlsp = require("mason-lspconfig")

    local setup_server = function(server)
      local ok, settings = pcall(require, "plugins.lsp.settings." .. server)
      if ok then
        vim.lsp.config(server, settings)
      end
      vim.lsp.enable(server)
    end

    for _, server in ipairs(mlsp.get_installed_servers()) do
      setup_server(server)
    end

    -- LSPs installed on system and available in PATH
    setup_server("clangd")

    mlsp.setup(opts)
  end,
}
