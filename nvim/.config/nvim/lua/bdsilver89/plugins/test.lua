return {
  {
    "vim-test/vim-test",
    keys = {
      { "<leader>tc", "<cmd>w|TestClass<cr>", desc = "Class" },
      { "<leader>tf", "<cmd>w|TestFile<cr>", desc = "File" },
      { "<leader>tl", "<cmd>w|TestLast<cr>", desc = "Last" },
      { "<leader>tn", "<cmd>w|TestNearest<cr>", desc = "Nearest" },
      { "<leader>ts", "<cmd>w|TestSuite<cr>", desc = "Suite" },
      { "<leader>tv", "<cmd>w|TestVisit<cr>", desc = "Visit" },
    },
    config = function()
      vim.g["test#strategy"] = "neovim"
      vim.g["test#neovim#term_position"] = "belowright"
      vim.g["test#neovim#preserve_screen"] = 1
    end,
  },
  {
    "nvim-neotest/neotest",
    dependencies = {
      "vim-test/vim-test",
      "nvim-neotest/neotest-go",
      "nvim-neotest/neotest-python",
      "nvim-neotest/neotest-plenary",
      "nvim-neotest/neotest-vim-test",
      {
        name = "neotest-cpp",
        dir = "/Users/brian/Developer/projects/neovim_plugins/neotest-cpp/develop",
      },
      "rouge8/neotest-rust",
    },
    keys = {
      {
        "<leader>tNF",
        "<cmd>w|lua require('neotest').run.run({vim.fn.expand('%'), strategy = 'dap'})<cr>",
        desc = "Debug File",
      },
      { "<leader>tNL", "<cmd>w|lua require('neotest').run.run_last({strategy = 'dap'})<cr>", desc = "Debug Last" },
      { "<leader>tNa", "<cmd>w|lua require('neotest').run.attach()<cr>", desc = "Attach" },
      { "<leader>tNf", "<cmd>w|lua require('neotest').run.run(vim.fn.expand('%'))<cr>", desc = "File" },
      { "<leader>tNl", "<cmd>w|lua require('neotest').run.run_last()<cr>", desc = "Last" },
      { "<leader>tNn", "<cmd>w|lua require('neotest').run.run()<cr>", desc = "Nearest" },
      { "<leader>tNN", "<cmd>w|lua require('neotest').run.run({strategy = 'dap'})<cr>", desc = "Debug Nearest" },
      { "<leader>tNo", "<cmd>w|lua require('neotest').output.open({ enter = true })<cr>", desc = "Output" },
      { "<leader>tNs", "<cmd>w|lua require('neotest').run.stop()<cr>", desc = "Stop" },
      { "<leader>tNS", "<cmd>w|lua require('neotest').summary.toggle()<cr>", desc = "Summary" },
    },
    config = function()
      local opts = {
        adapters = {
          -- require("neotest-vim-test")({ ignore_file_types = { "python", "vim", "lua" } }),
          require("neotest-vim-test"),
          require("neotest-python")({ dap = { justMyCode = false } }),
          require("neotest-plenary"),
          require("neotest-rust"),
          require("neotest-go"),
          require("neotest-cpp"),
        },
        -- consumers = {
        --   overseer = require("neotest.consumers.overseer"),
        -- },
        -- overseer = {
        --   enabled = true,
        --   force_default = true,
        -- },
      }
      require("neotest").setup(opts)
    end,
  },
  {
    "andythigpen/nvim-coverage",
    cmd = "Coverage",
    config = true,
  },
}
