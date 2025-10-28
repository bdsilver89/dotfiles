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
    },
  },
  config = function(_, opts)
    local mlsp = require("mason-lspconfig")

    for _, server in ipairs(mlsp.get_installed_servers()) do
      local ok, settings = pcall(require, "plugins.lsp.settings." .. server)
      if ok then
        vim.lsp.config(server, settings)
      end
    end

    mlsp.setup(opts)
  end,
}
