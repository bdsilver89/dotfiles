vim.pack.add({
  "https://github.com/mfussenegger/nvim-dap",
  "https://github.com/igorlfs/nvim-dap-view",
})

local dap = require("dap")
local dap_view = require("dap-view")

local lang = require("lang")
for name, adapter in pairs(lang.dap.adapters) do
  dap.adapters[name] = adapter
end
for ft, configs in pairs(lang.dap.configurations) do
  dap.configurations[ft] = vim.list_extend(dap.configurations[ft] or {}, configs)
end

dap_view.setup({})

dap.listeners.before.attach.dapui_config = function()
  vim.cmd("DapViewOpen")
end

dap.listeners.before.launch.dapui_config = function()
  vim.cmd("DapViewOpen")
end

dap.listeners.before.event_terminated.dapui_config = function()
  vim.cmd("DapViewClose")
end

dap.listeners.before.event_exited.dapui_config = function()
  vim.cmd("DapViewClose")
end

---@param config {type?:string, args?:string[]|fun():string[]?}
local function get_args(config)
  local args = type(config.args) == "function" and (config.args() or {}) or config.args or {} --[[@as string[] | string ]]
  local args_str = type(args) == "table" and table.concat(args, " ") or args --[[@as string]]

  config = vim.deepcopy(config)
  ---@cast args string[]
  config.args = function()
    local new_args = vim.fn.expand(vim.fn.input("Run with args: ", args_str)) ---@as string
    if config.type and config.type == "java" then
      ---@diagnostic disable-next-line: return-type-mismatch
      return new_args
    end
    return require("dap.utils").splitstr(new_args)
  end
  return config
end

local function map(l, r, desc)
  vim.keymap.set("n", l, r, { desc = desc })
end

--stylua: ignore start
vim.fn.sign_define("DapStopped", { text ="󰁕 ", texthl = "DiagnosticWarn", linehl = "DapStoppedLine", numhl = "DapStoppedLine" })
vim.fn.sign_define("DapBreakpoint", { text = " ", texthl = "DiagnosticInfo" })
vim.fn.sign_define("DapBreakpointCondition", { text = " ", texthl = "DiagnosticInfo" })
vim.fn.sign_define("DapBreakpointRejected", { text = " ", texthl = "DiagnosticError" })
vim.fn.sign_define("DapLogPoint", { text = ".>", texthl = "DiagnosticInfo" })
--stylua: ignore end

--stylua: ignore start
map("<leader>dB", function() require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: ")) end, "Breakpoint condition")
map("<leader>db", function() require("dap").toggle_breakpoint() end, "Breakpoint toggle")
map("<leader>dc", function() require("dap").continue() end, "Run/Continue")
map("<leader>da", function() require("dap").continue({ before = get_args }) end, "Run with args")
--stylua: ignore end
