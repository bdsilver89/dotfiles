return {
  {
    "nvim-treesitter",
    opts = { ensure_installed = { "python", "rst", "ninja" } },
  },

  {
    "mason.nvim",
    opts = { ensure_installed = { "ruff", "pyright" } },
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

  -- {
  --   "mfussenegger/nvim-dap",
  --   optional = true,
  --   dependencies = {
  --     "mfussenegger/nvim-dap-python",
  --     -- stylua: ignore
  --     keys = {
  --       { "<leader>dPt", function() require('dap-python').test_method() end, desc = "Debug Method", ft = "python" },
  --       { "<leader>dPc", function() require('dap-python').test_class() end, desc = "Debug Class", ft = "python" },
  --     },
  --     config = function()
  --       if vim.fn.has("win32") == 1 then
  --         require("dap-python").setup(require("utils").get_pkg_path("debugpy", "/venv/Scripts/pythonw.exe"))
  --       else
  --         require("dap-python").setup(require("utils").get_pkg_path("debugpy", "/venv/bin/python"))
  --       end
  --     end,
  --   },
  -- },
}
