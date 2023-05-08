return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      {
        "rcarriga/nvim-dap-ui",
        keys = {
          { "<leader>du", function() require("dapui").toggle({}) end, desc = "Dap UI" },
          { "<leader>de", function() require("dapui").eval() end,     mode = { "n", "v" }, desc = "Dap eval" },
        },
        opts = {},
        config = function(_, opts)
          local dap = require("dap")
          local dapui = require("dapui")
          dapui.setup(opts)
          dap.listeners.after.event_initialized["dapui_config"] = function()
            dapui.open({})
          end
          dap.listeners.beforef.event_terminated["dapui_config"] = function()
            dapui.close({})
          end
          dap.listeners.beforef.event_exited["dapui_config"] = function()
            dapui.close({})
          end

          dap.adapters.codelldb = {
            type = "server",
            port = "${port}",
            executable = {
              command = vim.fn.stdpath("data") .. "/mason/bin/codelldb",
              args = { "--port", "${port}" },
            },
          }

          dap.configurations.cpp = {
            {
              name = "codelldb",
              type = "codelldb",
              request = "launch",
              program = function()
                return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/")
              end,
              args = function()
                return vim.fn.input("Program args: ")
              end,
              cwd = "${workspaceFolder}",
              stopOnEntry = true,
              runInTerminal = true,
            }
          }

          dap.configurations.c = dap.configurations.cpp
          dap.configurations.rust = dap.configurations.cpp
        end,
      },
      {
        "theHamsta/nvim-dap-virtual-text",
        opts = {},
      },
      {
        "jay-babu/mason-nvim-dap.nvim",
        dependencies = "mason.nvim",
        cmd = { "DapInstall", "DapUninstall" },
        opts = {
          automatic_setup = true,
          handlers = {},
          ensure_installed = {
            "codelldb",
          }
        },
      },
    },
    keys = {
      {
        "<leader>dB",
        function() require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: ")) end,
        desc =
        "Breakpoint condition"
      },
      {
        "<leader>db",
        function() require("dap").set_breakpoint() end,
        desc =
        "Toggle breakpoint"
      },
      {
        "<leader>dc",
        function() require("dap").continue() end,
        desc =
        "Continue"
      },
      {
        "<leader>dC",
        function() require("dap").run_to_cursor() end,
        desc =
        "Run to cursor"
      },
      {
        "<leader>dg",
        function() require("dap").goto_() end,
        desc =
        "Goto next line (no execute)"
      },
      {
        "<leader>di",
        function() require("dap").step_into() end,
        desc =
        "Step into"
      },
      { "<leader>dj", function() require("dap").down() end, desc = "Down" },
      { "<leader>dk", function() require("dap").up() end,   desc = "Up" },
      {
        "<leader>dl",
        function() require("dap").run_last() end,
        desc =
        "Run last"
      },
      {
        "<leader>do",
        function() require("dap").step_out() end,
        desc =
        "Step out"
      },
      {
        "<leader>dO",
        function() require("dap").step_over() end,
        desc =
        "Step over"
      },
      {
        "<leader>dp",
        function() require("dap").pause() end,
        desc =
        "Pause"
      },
      {
        "<leader>dr",
        function() require("dap").repl.toggle() end,
        desc =
        "Toggle REPL"
      },
      {
        "<leader>ds",
        function() require("dap").session() end,
        desc =
        "Session"
      },
      {
        "<leader>dt",
        function() require("dap").terminate() end,
        desc =
        "Terminate"
      },
      {
        "<leader>dw",
        function() require("dap.ui.widgets").hover() end,
        desc =
        "Widgets"
      },
    },
    config = function()
      local icons = require("bdsilver89.config.icons")
      vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })

      for name, sign in pairs(icons.dap) do
        sign = type(sign) == "table" and sign or { sign }
        vim.fn.sign_define(
          "Dap" .. name,
          {
            text = sign[1],
            texthl = sign[2] or "DiagnosticInfo",
            linehl = sign[3],
            numhl = sign[3],
          }
        )
      end
    end,
  },
}
