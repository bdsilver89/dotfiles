return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, { "python" })
    end,
  },
  {
    "jose-elias-alvarez/null-ls.nvim",
    opts = function(_, opts)
      local nls = require("null-ls")
      table.insert(opts.sources, nls.builtins.formatting.black)
    end,
  },
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, { "debugpy", "black" })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        pyright = {
          settings = {
            python = {
              anaylsis = {
                autoImportCompletions = true,
                -- typeCheckingMode = "off",
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
                diagnosticMode = "workspace",
              },
            },
          },
        },
        ruff_lsp = {
          init_options = {
            settings = {
              args = {
                "--max-line-length=100",
              },
            },
          },
        },
      },
      setup = {
        pyright = function(_, _)
          local lsp_utils = require("bdsilver89.plugins.lsp.utils")
          lsp_utils.on_attach(function(client, buffer)
            if client.name == "pyright" then
              vim.keymap.set("n", "<leader>tC", function()
                require("dap-python").test_class()
              end, { buffer = buffer, desc = "Debug class" })
              vim.keymap.set("n", "<leader>tM", function()
                require("dap-python").test_method()
              end, { buffer = buffer, desc = "Debug Method" })
              vim.keymap.set("n", "<leader>tS", function()
                require("dap-python").debug_selection()
              end, { buffer = buffer, desc = "Debug Selection" })
            end
          end)
        end,
      },
    },
  },
  {
    "danymat/neogen",
    opts = {
      languages = {
        python = {
          template = {
            annotation_convention = "google_docstrings",
          },
        },
      },
    },
  },
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "mfussenegger/nvim-dap-python",
    },
    opts = {
      setup = {
        debugpy = function(_, _)
          require("dap-python").setup("python", {})
          table.insert(require("dap").configurations.python, {
            type = "python",
            request = "attach",
            connect = {
              port = 5678,
              host = "127.0.0.1",
            },
            mode = "remote",
            name = "container attach debug",
            cwd = vim.fn.getcwd(),
            pathmappings = {
              {
                localroot = function()
                  return vim.fn.input("local code folder > ", vim.fn.getcwd(), "file")
                end,
                remoteroot = function()
                  return vim.fn.input("container code folder > ", "/", "file")
                end,
              },
            },
          })
        end,
      },
    },
  },
}
