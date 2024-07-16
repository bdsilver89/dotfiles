local lsp = vim.g.python_lsp or "pyright"
local ruff = vim.g.python_ruff or "ruff_lsp"

return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = { "python" },
    },
  },

  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        pyright = {
          enabled = lsp == "pyright",
        },
        basedpyright = {
          enabled = lsp == "basedpyright",
        },
        [lsp] = {
          enabled = true,
        },
        ruff_lsp = {
          enabled = ruff == "ruff_lsp",
        },
        ruff = {
          enabled = ruff == "ruff",
        },
        [ruff] = {
          -- keys = {
          --   {
          --     "<leader>co",
          --     LazyVim.lsp.action["source.organizeImports"],
          --     desc = "Organize Imports",
          --   },
          -- },
        },
      },
      -- setup = {
      --   [ruff] = function()
      --     LazyVim.lsp.on_attach(function(client, _)
      --       -- Disable hover in favor of Pyright
      --       client.server_capabilities.hoverProvider = false
      --     end, ruff)
      --   end,
      -- },
    },
  },

  {
    "williamboman/mason.nvim",
    optional = true,
    opts = {
      ensure_installed = {
        "black",
      },
    },
  },

  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        ["python"] = { "black" },
      },
    },
  },

  {
    "nvim-neotest/neotest",
    optional = true,
    dependencies = {
      "nvim-neotest/neotest-python",
    },
    opts = {
      adapters = {
        ["neotest-python"] = {},
      },
    },
  },

  -- TODO: implement
  -- {
  --   "mfussenegger/nvim-dap",
  --   optional = true,
  --   dependencies = {
  --     "mfussenegger/nvim-dap-python",
  --   },
  --   -- stylua: ignore
  --   keys = {
  --     { "<leader>dPt", function() require('dap-python').test_method() end, desc = "Debug Method", ft = "python" },
  --     { "<leader>dPc", function() require('dap-python').test_class() end, desc = "Debug Class", ft = "python" },
  --   },
  --   NOTE: venv selector from mason
  -- },

  {
    "hrsh7th/nvim-cmp",
    opts = function(_, opts)
      opts.auto_brackets = opts.auto_brackets or {}
      table.insert(opts.auto_brackets, "python")
    end,
  },

  -- {
  --   "linux-cultist/venv-selector.nvim",
  --   branch = "regexp", -- Use this branch for the new version
  --   cmd = "VenvSelect",
  --   ft = "python",
  --   opts = {
  --     settings = {
  --       options = {
  --         notify_user_on_venv_activation = true,
  --       },
  --     },
  --   },
  --   keys = {
  --     { "<leader>cv", "<cmd>:VenvSelect<cr>", desc = "Select VirtualEnv", ft = "python" },
  --   },
  -- },
}
