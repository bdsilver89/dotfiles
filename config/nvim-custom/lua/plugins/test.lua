return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-neotest/neotest-python",
      "orjangj/neotest-ctest",
    },
    -- stylua: ignore
    keys = {
      { "<leader>tt", function() require("neotest").run.run(vim.fn.expand("%")) end,                      desc = "Run file" },
      { "<leader>tT", function() require("neotest").run.run(vim.uv.cwd()) end,                            desc = "Run all test files" },
      { "<leader>tr", function() require("neotest").run.run() end,                                        desc = "Run nearest" },
      { "<leader>tl", function() require("neotest").run.run_last() end,                                   desc = "Run last" },
      { "<leader>ts", function() require("neotest").summary.toggle() end,                                 desc = "Toggle summary" },
      { "<leader>to", function() require("neotest").output.open({ enter = true, auto_close = true }) end, desc = "Show output" },
      { "<leader>tO", function() require("neotest").output_panel.toggle() end,                            desc = "Toggle output panel" },
      { "<leader>tS", function() require("neotest").run.stop() end,                                       desc = "Stop" },
      { "<leader>tw", function() require("neotest").watch.toggle(vim.fn.expand("%")) end,                 desc = "Toggle watch" },
      { "<leader>td", function() require("neotest").run.run({ strategy = "dap" }) end,                    desc = "Debug nearest" },
    },
    opts = function()
      return {
        adapters = {
          ["rustaceanvim.neotest"] = {},
          ["neotest-python"] = {},
          ["neotest-ctest"] = {
            extra_args = {
              "--output-on-failure",
            },
            is_test_file = function(file)
              local lib = require("neotest.lib")
              local elems = vim.split(file, lib.files.sep, { plain = true })
              local name, extension = unpack(vim.split(elems[#elems], ".", { plain = true }))
              local supported_extensinos = { "cpp", "cc", "cxx" }
              return vim.tbl_contains(supported_extensinos, extension)
                  and (vim.endswith(name, "_test") or vim.endswith(name, "Test"))
                or false
            end,
          },
        },
        -- consumers = {
        --   overseer = require("neotest.consumers.overseer"),
        -- },
        status = { virtual_text = true },
        output = { open_on_run = true },
        quickfix = {
          open = function()
            -- require("trouble").open({ mode = "quickfix", focus = false })
            vim.cmd("copen")
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
