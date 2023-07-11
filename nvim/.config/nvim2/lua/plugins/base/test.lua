return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "nvim-neotest/neotest-vim-test",
      "vim-test/vim-test",
      "stevearc/overseer.nvim",
    },
    keys = {
    },
    opts = function()
      return {
        adapters = {
          require "neotest-vim-test" {
            ignore_file_types = { "python", "vim", "lua" },
          },
        },
        status = { virtual_text = true },
        output = { open_on_run = true },
      }
    end,
    config = function(_, opts)
      local neotest_ns = vim.api.nvim_create_namespace("neotest")
      vim.diagnostic.config({
        virtual_text = {
          format = function(diagnostic)
            local message = diagnostic.message:gsub("\n", " "):gsub("\t", " "):gsub("%s+", " "):gsub("^%s+",  "")
            return message
          end,
        },
      }, neotest_ns)
      require("neotest").setup(opts)
    end,
  }
}
