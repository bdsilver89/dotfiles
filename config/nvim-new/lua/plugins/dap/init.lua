return {
  "mfussenegger/nvim-dap",
  dependencies = {
    {
      "rcarriga/nvim-dap-ui",
      opts = {},
    },
    {
      "theHamsta/nvim-dap-virtual-text",
      opts = {
        commented = true,
      }
    },
  },
  config = function()
    local dap = require("dap")
    vim.fn.sign_define("DapBreakpoint", { text = "", texthl = "DiagnosticSignError", linehl = "", numhl = "" })

    local dapui = require("dapui")
    dap.listeners.after.event_initialized["dapui_config"] = function()
      dapui.open()
    end

    dap.listeners.before.event_terminated["dapui_config"] = function()
      dapui.close()
    end

    dap.listeners.before.event_exited["dapui_config"] = function()
      dapui.close()
    end


    local adapters = { "codelldb" }
    for _, adapter in ipairs(adapters) do
      require("plugins.dap.settings." .. adapter)
    end
  end,
}
