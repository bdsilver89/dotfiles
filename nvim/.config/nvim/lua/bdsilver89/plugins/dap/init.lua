-- check for .vscode/launch.json file in working directory to load
local function load_launchjs()
  local launch_json_path = vim.loop.cwd() .. "/.vscode/launch.json"
  if vim.fn.filereadable(launch_json_path) then
    require("dap.ext.vscode").load_launchjs(launch_json_path)
  end
end

return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      { "rcarriga/nvim-dap-ui" },
      { "theHamsta/nvim-dap-virtual-text" },
      { "nvim-telescope/telescope-dap.nvim" },
      { "jbyuki/one-small-step-for-vimkind" },
      { "jay-babu/mason-nvim-dap.nvim" },
      { "LiadOz/nvim-dap-repl-highlights", opts = {} },
    },
    -- stylua: ignore
    keys = {
      { "<leader>dR", function() require("dap").run_to_cursor() end, desc = "Run to Cursor", },
      { "<leader>dE", function() require("dapui").eval(vim.fn.input "[Expression] > ") end, desc = "Evaluate Input", },
      { "<leader>dC", function() require("dap").set_breakpoint(vim.fn.input "[Condition] > ") end, desc = "Conditional Breakpoint", },
      { "<leader>dT", function() require("dap").clear_breakpoints() end, desc = "Clear Breakpoints", },
      { "<leader>dU", function() require("dapui").toggle() end, desc = "Toggle UI", },
      { "<leader>db", function() require("dap").step_back() end, desc = "Step Back", },
      { "<leader>dd", function() require("dap").disconnect() end, desc = "Disconnect", },
      { "<leader>de", function() require("dapui").eval() end, mode = {"n", "v"}, desc = "Evaluate", },
      { "<leader>dg", function() require("dap").session() end, desc = "Get Session", },
      { "<leader>dh", function() require("dap.ui.widgets").hover() end, desc = "Hover Variables", },
      { "<leader>dS", function() require("dap.ui.widgets").scopes() end, desc = "Scopes", },
      { "<leader>di", function() require("dap").step_into() end, desc = "Step Into", },
      { "<leader>do", function() require("dap").step_over() end, desc = "Step Over", },
      { "<leader>dl", function() require("dap").run_last() end, desc = "Run Last" },
      { "<leader>dp", function() require("dap").pause.toggle() end, desc = "Pause", },
      { "<leader>dq", function() require("dap").close() end, desc = "Quit", },
      { "<leader>dr", function() require("dap").repl.toggle() end, desc = "Toggle REPL", },
      { "<leader>dt", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint", },
      { "<leader>dx", function() require("dap").terminate() end, desc = "Terminate", },
      { "<leader>du", function() require("dap").step_out() end, desc = "Step Out", },
      {
        "<leader>dc",
        function()
          load_launchjs()
          require("dap").continue()
        end,
        desc = "Continue",
      },
      {
        "<leader>ds",
        function()
          load_launchjs()
          require("dap").continue()
        end,
        desc = "Start",
      },
    },
    opts = {
      setup = {
        osv = function(_, _)
          require("bdsilver89.plugins.dap.lua").setup({ commented = true })
        end,
      },
    },
    config = function(plugin, opts)
      local utils = require("bdsilver89.utils")
      local signs = {
        { name = "DapStopped", text = utils.get_icon("DapStopped"), texthl = "DiagnosticWarn" },
        { name = "DapBreakpoint", text = utils.get_icon("DapBreakpoint"), texthl = "DiagnosticInfo" },
        { name = "DapBreakpointRejected", text = utils.get_icon("DapBreakpointRejected"), texthl = "DiagnosticError" },
        { name = "DapBreakpointCondition", text = utils.get_icon("DapBreakpointCondition"), texthl = "DiagnosticInfo" },
        { name = "DapLogPoint", text = utils.get_icon("DapLogPoint"), texthl = "DiagnosticInfo" },
      }
      for _, sign in ipairs(signs) do
        vim.fn.sign_define(sign.name, sign)
      end

      require("nvim-dap-virtual-text").setup({
        commented = true,
      })

      local dap = require("dap")
      local dapui = require("dapui")
      dapui.setup({})

      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end

      for k, _ in pairs(opts.setup) do
        opts.setup[k](plugin, opts)
      end
    end,
  },
  {
    "jay-babu/mason-nvim-dap.nvim",
    dependencies = {
      "mason.nvim",
    },
    cmd = {
      "DapInstall",
      "DapUninstall",
    },
    opts = {
      automatic_setup = true,
      handlers = {},
      ensure_installed = {},
    },
  },
}
