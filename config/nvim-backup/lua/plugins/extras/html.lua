return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, { "html", "css" })
    end,
  },
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, { "prettierd" })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        html = {},
        emmet_ls = {
          init_options = {
            html = {
              options = {
                ["bem.enabled"] = true,
              },
            },
          },
        },
        cssls = {},
      },
    },
  },
  {
    "jose-elias-alvarez/null-ls.nvim",
    opts = function(_, opts)
      local nls = require("null-ls")
      vim.list_extend(opts.sources, nls.builtins.formatting.prettierd)
    end
  },
  {
    "folke/which-key.nvim",
    opts = {
      defaults = {
        ["<leader>z"] = { name = "+System" },
        ["<leader>zC"] = { name = "+Color" },
      },
    },
  },
  {
    "uga-rosa/ccc.nvim",
    opts = {},
    cmd = { "CccPick", "CccConvert", "CccHighlighterEnable", "CccHighlighterDisable", "CccHighlighterToggle" },
    keys = {
      { "<leader>zCp", "<cmd>CccPick<cr>",              desc = "Pick" },
      { "<leader>zCc", "<cmd>CccConvert<cr>",           desc = "Convert" },
      { "<leader>zCh", "<cmd>CccHighlighterToggle<cr>", desc = "Toggle Highlighter" },
    },
  },
}
