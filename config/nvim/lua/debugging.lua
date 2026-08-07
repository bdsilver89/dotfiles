vim.pack.add({
  "https://github.com/mfussenegger/nvim-dap",
  "https://github.com/igorlfs/nvim-dap-view",
})

vim.schedule(function()
  local dap = require("dap")
  local dap_view = require("dap-view")

  dap_view.setup({
    auto_toggle = true,
  })

  dap.listeners.before.attach.dap_view_config = function()
    dap_view.open()
  end

  dap.listeners.before.launch.dap_view_config = function()
    dap_view.open()
  end

  dap.listeners.before.event_terminated.dap_view_config = function()
    dap_view.close()
  end

  dap.listeners.before.event_exited.dap_view_config = function()
    dap_view.close()
  end
end)

vim.fn.sign_define(
  "DapStopped",
  { text = "󰁕 ", texthl = "DiagnostcWarn", linehl = "DapStoppedLine", numhl = "DapStoppedLine" }
)
vim.fn.sign_define("DapBreakpoint", { text = " ", texthl = "DiagnostcInfo", linehl = "", numhl = "" })
vim.fn.sign_define("DapBreakpointCondition", { text = " ", texthl = "DiagnostcInfo", linehl = "", numhl = "" })
vim.fn.sign_define("DapBreakpointRejected", { text = " ", texthl = "DiagnostcError", linehl = "", numhl = "" })
vim.fn.sign_define("DapLogPoint", { text = ".>", texthl = "DiagnostcError", linehl = "", numhl = "" })

---@param config {type?:string, args?:string[]|fun():string[]?}
local function get_args(config)
  local args = type(config.args) == "function" and (config.args() or {}) or config.args or {} --[[@as string[] | string ]]
  local args_str = type(args) == "table" and table.concat(args, " ") or args --[[@as string]]

  config = vim.deepcopy(config)
  ---@cast args string[]
  config.args = function()
    local new_args = vim.fn.expand(vim.fn.input("Run with args: ", args_str)) --[[@as string]]
    if config.type and config.type == "java" then
      ---@diagnostic disable-next-line: return-type-mismatch
      return new_args
    end
    return require("dap.utils").splitstr(new_args)
  end
  return config
end

vim.keymap.set("n", "<leader>dc", function()
  require("dap").continue()
end, { desc = "Continue" })
vim.keymap.set("n", "<leader>da", function()
  require("dap").continue({ before = get_args })
end, { desc = "Continue" })
vim.keymap.set("n", "<leader>di", function()
  require("dap").step_into()
end, { desc = "Step Into" })
vim.keymap.set("n", "<leader>do", function()
  require("dap").step_over()
end, { desc = "Step Over" })
vim.keymap.set("n", "<leader>dO", function()
  require("dap").step_out()
end, { desc = "Step Out" })
vim.keymap.set("n", "<leader>dt", function()
  require("dap").terminate()
end, { desc = "Terminate" })

-- Breakpoints
vim.keymap.set("n", "<leader>db", function()
  require("dap").toggle_breakpoint()
end, { desc = "Toggle Breakpoint" })
vim.keymap.set("n", "<leader>dB", function()
  require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
end, { desc = "Conditional Breakpoint" })

-- UI Layout Toggling
vim.keymap.set("n", "<leader>du", function()
  require("dap-view").toggle()
end, { desc = "Toggle DAP View UI" })
