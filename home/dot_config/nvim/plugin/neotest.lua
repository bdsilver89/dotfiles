local add = require("pack").add
local add_on_filetype = require("pack").add_on_filetype

add_on_filetype("python", {
  {
    src = "nvim-neotest/neotest-python",
    setup = false,
  },
})
add_on_filetype("java", {
  {
    src = "rcasia/neotest-java",
    setup = false,
    on_setup = function()
      vim.cmd("NeotestJava setup")
    end,
  },
})
add_on_filetype({ "c", "cpp", "cmake" }, {
  {
    src = "orjangj/neotest-ctest",
    setup = false,
  },
})

add({
  {
    src = "nvim-neotest/nvim-nio",
    setup = false,
  },
  {
    src = "nvim-neotest/neotest",
    opts = function()
      return {
        adapters = {
          require("neotest-python"),
          require("neotest-java"),
          require("neotest-ctest"),
        },
      }
    end,
    on_setup = function()
      local map = function(lhs, rhs, desc)
        vim.keymap.set("n", lhs, rhs, { desc = desc })
      end

      -- stylua: ignore start
      map("<leader>ta", function() require("neotest").run.attach() end, "Attach to test")
      map("<leader>tt", function() require("neotest").run.run(vim.fn.expand("%")) end, "Run tests in file")
      map("<leader>tT", function() require("neotest").run.run(vim.uv.cwd()) end, "Run all test files")
      map("<leader>tr", function() require("neotest").run.run() end, "Run nearest test")
      map("<leader>tl", function() require("neotest").run.run_last() end, "Run last test")
      map("<leader>ts", function() require("neotest").summary.toggle() end, "Toggle test summary")
      map("<leader>to", function() require("neotest").output.open({ enter = true, auto_close = true}) end, "Open test output")
      map("<leader>tO", function() require("neotest").output_panel.toggle() end, "Toggle test output panel")
      map("<leader>tS", function() require("neotest").run.stop() end, "Stop tests")
      map("<leader>tw", function() require("neotest").watch.toggle(vim.fn.expand("%")) end, "Toggle test watch")
      -- stylua: ignore end
    end,
  },
})
