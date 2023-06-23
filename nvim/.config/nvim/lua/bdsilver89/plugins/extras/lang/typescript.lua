if not require("bdsilver89.config.lang").langs.typescript then
  return {}
end

return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, { "javascript", "typescript", "tsx" })
    end,
  },
  {
    "jose-elias-alvarez/null-ls.nvim",
    opts = function(_, opts)
      table.insert(opts.sources, require("typescript.extensions.null-ls.code-actions"))
    end,
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "jose-elias-alvarez/typescript.nvim",
    },
    opts = {
      servers = {
        tsserver = {},
        tailwindcss = {},
      },
      setup = {
        tsserver = function(_, opts)
          local lsp_utils = require("bdsilver89.plugins.lsp.utils")
          lsp_utils.on_attach(function(client, buffer)
            if client.name == "tsserver" then
              vim.keymap.set(
                "n",
                "<leader>co",
                "TypescriptOrganizeImports",
                { buffer = buffer, desc = "Organize Imports" }
              )
              vim.keymap.set("n", "<leader>cR", "TypescriptRenameFile", { buffer = buffer, desc = "Rename File" })
            end
          end)
          require("typescript").setup({ server = opts })
          return true
        end,
      },
    },
  },
  {
    "danymat/neogen",
    opts = {
      languages = {
        javascript = {
          template = {
            annotation_convention = "jsdoc",
          },
        },
        typescript = {
          template = {
            annotation_convention = "tsdoc",
          },
        },
        typescriptreact = {
          template = {
            annotation_convention = "tsdoc",
          },
        },
      },
    },
  },
}
