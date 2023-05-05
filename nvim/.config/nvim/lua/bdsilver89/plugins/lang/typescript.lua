return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      table.insert(opts.ensure_installed, "javascript")
      table.insert(opts.ensure_installed, "typescript")
      table.insert(opts.ensure_installed, "tsx" )
    end,
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "jose-elias-alvarez/typescript.nvim"
    },
    opts = {
      servers = {
        tsserver = {
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
        eslint = {
          settings = {
            workingDirectory = {
              mode = "auto"
            },
          },
        },
      },
      setup = {
        tsserver = function(_, opts)
          require("bdsilver89.utils").on_attach(function(client, buffer)
            if client.name == "tsserver" then
              vim.keymap.set("n", "<leader>co",
                "<cmd>TypescriptOrganizeImports<cr>",
                { buffer = buffer, desc = "Organize imports" })
              vim.keymap.set("n", "<leader>cR", "<cmd>TypescriptRenameFile<cr>",
                { buffer = buffer, desc = "Rename file" })
            end
          end)
          require("typescript").setup({ server = opts })
          return true
        end,
        eslint = function()
          vim.api.nvim_create_autocmd("BufWritePre", {
            callback = function(event)
              if require("lspconfig.util").get_active_client_by_name(event.buf, "eslint") then
                vim.cnd("EslintFixAll")
              end
            end,
          })
        end,
      },
    },
  },
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      table.insert(opts.ensure_installed, "prettierd")
    end,
  },
  {
    "jose-elias-alvarez/null-ls.nvim",
    opts = function(_, opts)
      local nls = require("null-ls")
      table.insert(opts.sources, nls.builtins.formatting.prettierd)
      table.insert(opts.sources, require("typescript.extensions.null-ls.code-actions"))
    end,
  },
}
