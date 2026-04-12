vim.pack.add({
  "https://github.com/mfussenegger/nvim-dap",
  "https://github.com/igorlfs/nvim-dap-view",
})

local dap = require("dap")
local dv = require("dap-view")

local codelldb_bin = vim.fn.stdpath("data") .. "/mason/bin/codelldb"

dap.adapters.codelldb = {
  type = "server",
  port = "${port}",
  executable = {
    command = codelldb_bin,
    args = { "--port", "${port}" },
  },
}

local cpp_config = {
  {
    name = "Launch executable",
    type = "codelldb",
    request = "launch",
    program = function()
      return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
    end,
    cwd = "${workspaceFolder}",
    stopOnEntry = false,
  },
  {
    name = "Attach to process",
    type = "codelldb",
    request = "attach",
    pid = require("dap.utils").pick_process,
    cwd = "${workspaceFolder}",
  },
}

dap.configurations.cpp = cpp_config
dap.configurations.c = cpp_config
dap.configurations.rust = cpp_config

dv.setup()

dap.listeners.before.attach["dap-view-config"] = function() dv.open() end
dap.listeners.before.launch["dap-view-config"] = function() dv.open() end
dap.listeners.before.event_terminated["dap-view-config"] = function() dv.close() end
dap.listeners.before.event_exited["dap-view-config"] = function() dv.close() end

local map = function(lhs, rhs, desc)
  vim.keymap.set("n", lhs, rhs, { desc = desc })
end

map("<leader>dc", dap.continue, "DAP Continue")
map("<leader>dn", dap.step_over, "DAP Step Over (next)")
map("<leader>di", dap.step_into, "DAP Step Into")
map("<leader>do", dap.step_out, "DAP Step Out")
map("<leader>db", dap.toggle_breakpoint, "DAP Toggle Breakpoint")
map("<leader>dB", function()
  dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
end, "DAP Conditional Breakpoint")
map("<leader>dr", dap.repl.toggle, "DAP REPL")
map("<leader>dl", dap.run_last, "DAP Run Last")
map("<leader>du", dv.toggle, "DAP View Toggle")
