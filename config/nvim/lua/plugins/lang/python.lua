return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "ninja", "python", "rst", "toml" })
      end
    end,
  },
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "black" })
      end
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        pyright = {},
        -- FIX:
        -- ruff_lsp = {
        --   keys = {
        --     {
        --       "<leader>co",
        --       function()
        --         vim.lsp.buf.code_action({
        --           apply = true,
        --           context = {
        --             only = { "source.organizeImports" },
        --             diagnostics = {},
        --           },
        --         })
        --       end,
        --       desc = "Organize imports",
        --     },
        --   },
        -- },
      },
      setup = {
        ruff_lsp = function()
          require("utils").lsp.on_attach(function(client, _)
            if client.name == "ruff_lsp" then
              client.server_capabilities.hoverProvider = false
            end
          end)
        end,
      },
    },
  },
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        ["python"] = { "black" },
      },
    },
  },
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/neotest-python",
    },
    opts = {
      adapters = {
        ["neotest-python"] = {},
      },
    },
  },
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "mfussenegger/nvim-dap-python",
      -- stylua: ignore
      keys = {
        { "<leader>dPt", function() require("dap-python").test_method() end, desc = "Debug method", ft = "python" },
        { "<leader>dPc", function() require("dap-python").test_class() end, desc = "Debug class", ft = "python" },
      },
      config = function()
        local path = require("mason-registry").get_package("debugpy"):get_install_path()
        require("dap-python").setup(path .. "/venv/bin/python")
      end,
    },
  },
  {
    "linux-cultist/venv-selector.nvim",
    cmd = "VenvSelect",
    keys = {
      { "<leader>cv", "<cmd>:VenvSelect<cr>", desc = "Select virtualenv" },
    },
    opts = function(_, opts)
      if require("util").has("nvim-dap-python") then
        opts.dap_enabled = true
      end
      return vim.tbl_deep_extend("force", opts, {
        name = {
          "venv",
          ".venv",
          "env",
          ".env",
        },
      })
    end,
  },
}
