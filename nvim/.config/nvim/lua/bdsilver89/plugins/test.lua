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
      -- "nvim-neotest/neotest-go",
      "nvim-neotest/neotest-python",
      -- "nvim-neotest/neotest-plenary",
      "nvim-neotest/neotest-vim-test",
      "rouge8/neotest-rust",
    },
    keys = {
      {
        "<leader>tNF",
        "<cmd>w|lua require('neotest').run.run({vim.fn.expand('%'), strategy = 'dap'})<cr>",
        desc = "Debug File",
      },
      -- { "<leader>tNL", "<cmd>w|lua require('neotest').run.run_last({strategy = 'dap'})<cr>", desc = "Debug Last" },
      { "<leader>tNa", "<cmd>w|lua require('neotest').run.attach()<cr>", desc = "Attach" },
      { "<leader>tNf", "<cmd>w|lua require('neotest').run.run(vim.fn.expand('%'))<cr>", desc = "File" },
      { "<leader>tNl", "<cmd>w|lua require('neotest').run.run_last()<cr>", desc = "Last" },
      { "<leader>tNn", "<cmd>w|lua require('neotest').run.run()<cr>", desc = "Nearest" },
      { "<leader>tNN", "<cmd>w|lua require('neotest').run.run({strategy = 'dap'})<cr>", desc = "Debug Nearest" },
      { "<leader>tNo", "<cmd>w|lua require('neotest').output.open({ enter = true })<cr>", desc = "Output" },
      { "<leader>tNs", "<cmd>w|lua require('neotest').run.stop()<cr>", desc = "Stop" },
      { "<leader>tNS", "<cmd>w|lua require('neotest').summary.toggle()<cr>", desc = "Summary" },
      {
        "<leader>tNd",
        function()
          require("neotest").run.run({ strategy = "dap" })
        end,
        desc = "Debug ",
      },
    },
    opts = {
      adapters = {
        ["neotest-vim-test"] = {},
        -- ["neotest-go"] = {},
        ["neotest-python"] = {
          dap = { justMyCode = false },
        },
        -- ["neotest-plenary"] = {},
        ["neotest-rust"] = {},
      },
      status = {
        virtual_text = true,
      },
      output = {
        open_on_run = true,
      },
      quickfix = {
        open = function()
          if require("bdsilver89.utils").has("trouble.nvim") then
            vim.cmd([[Trouble quickfix]])
          else
            vim.cmd("copen")
          end
        end,
      },
      -- consumers = {
      --   overseer = require("neotest.consumers.overseer"),
      -- },
      -- overseer = {
      --   enabled = true,
      --   force_default = true,
      -- }
    },
    config = function(_, opts)
      local neotest_ns = vim.api.nvim_create_namespace("neotest")
      vim.diagnostic.config({
        virtual_text = {
          format = function(diagnostic)
            local message = diagnostic.message:gsub("\n", " "):gsub("\t", " "):gsub("%s+", " "):gsub("^%s+", "")
            return message
          end,
        },
      }, neotest_ns)

      if opts.adapters then
        local adapters = {}
        for name, config in pairs(opts.adapters or {}) do
          if type(name) == "number" then
            if type(config) == "string" then
              config = require(config)
            end
            adapters[#adapters + 1] = config
          elseif config ~= false then
            local adapter = require(name)
            if type(config) == "table" and not vim.tbl_isempty(config) then
              local meta = getmetatable(adapter)
              if adapter.setup then
                adapter.setup(config)
              elseif meta and meta.__call then
                adapter(config)
              else
                error("Adapter " .. name .. " does not support setup")
              end
            end
            adapters[#adapters + 1] = adapter
          end
        end
        opts.adapters = adapters
      end

      require("neotest").setup(opts)

      --   local opts = {
      --     adapters = {
      --       -- require("neotest-vim-test")({ ignore_file_types = { "python", "vim", "lua" } }),
      --       require("neotest-vim-test"),
      --       require("neotest-python")({ dap = { justMyCode = false } }),
      --       require("neotest-plenary"),
      --       require("neotest-rust"),
      --       require("neotest-go"),
      --     },
      --     -- consumers = {
      --     --   overseer = require("neotest.consumers.overseer"),
      --     -- },
      --     -- overseer = {
      --     --   enabled = true,
      --     --   force_default = true,
      --     -- },
      --   }
      --   require("neotest").setup(opts)
    end,
  },
}
