return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, { "typescript", "javascript", "tsx" })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = { "jose-elias-alvarez/typescript.nvim" },
    opts = {
      servers = {
        tsserver = {
          keys = {
            { "<leader>co", "<cmd>TypescriptOrganizeImports<cr>", desc = "Organize imports" },
            { "<leader>cR", "<cmd>TypescriptRenameFile<cr>",      desc = "Rename file" },
          },
          settings = {
            typescript = {
              format = {
                indentSize = vim.o.shiftwidth,
                convertTabsToSpaces = vim.o.expandtab,
                tabSize = vim.o.tabstop,
              },
            },
            javascript = {
              format = {
                indentSize = vim.o.shiftwidth,
                convertTabsToSpaces = vim.o.expandtab,
                tabSize = vim.o.tabstop,
              },
            },
            completions = {
              completeFunctionCalls = true,
            },
          },
        },
      },
    },
    setup = {
      tsserver = function(_, opts)
        require("typescript").setup({ server = opts })
        return true
      end,
    },
  },
  {
    "jose-elias-alvarez/null-ls.nvim",
    opts = function(_, opts)
      table.insert(opts.sources, require("typescript.extensions.null-ls.code-actions"))
    end,
  },
  {
    "mfussenegger/nvim-dap",
    optional = true,
    dependencies = {
      {
        "williamboman/mason.nvim",
        opts = function(_, opts)
          opts.ensure_installed = opts.ensure_installed or {}
          table.insert(opts.ensure_installed, "js-debug-adapter")
        end,
      },
    },
    opts = function()
      local dap = require("dap")
      if not dap.adapters["pwa-node"] then
        require("dap").adapters["pwa-node"] = {
          type = "server",
          host = "localhost",
          port = "${port}",
          executable = {
            command = "node",
            -- Make sure to update this path to point to your installation
            args = {
              require("mason-registry").get_package("js-debug-adapter"):get_install_path()
              .. "/js-debug/src/dapDebugServer.js",
              "${port}",
            },
          },
        }
      end
      for _, language in ipairs({ "typescript", "javascript" }) do
        if not dap.configurations[language] then
          dap.configurations[language] = {
            {
              type = "pwa-node",
              request = "launch",
              name = "Launch file",
              program = "${file}",
              cwd = "${workspaceFolder}",
            },
            {
              type = "pwa-node",
              request = "attach",
              name = "Attach",
              processId = require("dap.utils").pick_process,
              cwd = "${workspaceFolder}",
            },
          }
        end
      end
    end,
  },
}
