return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-neotest/neotest-python",
    },
    -- stylua: ignore
    keys = {
      { "<leader>Tt", function() require("neotest").run.run(vim.fn.expand("%")) end,                      desc = "Run file" },
      { "<leader>TT", function() require("neotest").run.run(vim.uv.cwd()) end,                            desc = "Run all test files" },
      { "<leader>Tr", function() require("neotest").run.run() end,                                        desc = "Run nearest" },
      { "<leader>Tl", function() require("neotest").run.run_last() end,                                   desc = "Run last" },
      { "<leader>Ts", function() require("neotest").summary.toggle() end,                                 desc = "Toggle summary" },
      { "<leader>To", function() require("neotest").output.open({ enter = true, auto_close = true }) end, desc = "Show output" },
      { "<leader>TO", function() require("neotest").output_panel.toggle() end,                            desc = "Toggle output panel" },
      { "<leader>TS", function() require("neotest").run.stop() end,                                       desc = "Stop" },
      { "<leader>Tw", function() require("neotest").watch.toggle(vim.fn.expand("%")) end,                 desc = "Toggle watch" },
      { "<leader>Td", function() require("neotest").run.run({ strategy = "dap" }) end,                    desc = "Debug nearest" },
    },
    opts = function()
      return {
        adapters = {
          ["rustaceanvim.neotest"] = {},
        },
        consumers = {
          overseer = require("neotest.consumers.overseer"),
        },
        status = { virtual_text = true },
        output = { open_on_run = true },
        quickfix = {
          open = function()
            require("trouble").open({ mode = "quickfix", focus = false })
          end,
        },
      }
    end,
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

      local adapters = {}
      for name, config in pairs(opts.adapters) do
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
            elseif adapter.adapter then
              adapter.adapter(config)
              adapter = adapter.adapter
            elseif meta and meta.__call then
              adapter = adapter(config)
            else
              error("Adapater " .. name .. " does not support setup")
            end
          end
          adapters[#adapters + 1] = adapter
        end
      end

      require("neotest").setup(opts)
    end,
  },
}
