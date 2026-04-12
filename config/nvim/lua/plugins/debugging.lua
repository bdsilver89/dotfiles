vim.pack.add({
  "https://github.com/mfussenegger/nvim-dap",
  "https://github.com/igorlfs/nvim-dap-view",
})

local dap = require("dap")
local dv = require("dap-view")

for _, file in ipairs(vim.api.nvim_get_runtime_file("dap/*.lua", true)) do
  local name = vim.fn.fnamemodify(file, ":t:r")
  local ok, spec = pcall(dofile, file)
  if ok and type(spec) == "table" then
    if spec.adapter then
      dap.adapters[name] = spec.adapter
    end
    for _, ft in ipairs(spec.filetypes or {}) do
      dap.configurations[ft] = dap.configurations[ft] or {}
      vim.list_extend(dap.configurations[ft], spec.configurations or {})
    end
  end
end

dv.setup()

dap.listeners.before.attach["dap-view-config"] = function()
  dv.open()
end
dap.listeners.before.launch["dap-view-config"] = function()
  dv.open()
end
dap.listeners.before.event_terminated["dap-view-config"] = function()
  dv.close()
end
dap.listeners.before.event_exited["dap-view-config"] = function()
  dv.close()
end

local map = function(lhs, rhs, desc)
  vim.keymap.set("n", lhs, rhs, { desc = desc })
end

-- stylua: ignore start
map("<leader>dc", dap.continue, "DAP Continue")
map("<leader>dn", dap.step_over, "DAP Step Over (next)")
map("<leader>di", dap.step_into, "DAP Step Into")
map("<leader>do", dap.step_out, "DAP Step Out")
map("<leader>db", dap.toggle_breakpoint, "DAP Toggle Breakpoint")
map("<leader>dB", function() dap.set_breakpoint(vim.fn.input("Breakpoint condition: ")) end, "DAP Conditional Breakpoint")
map("<leader>dr", dap.repl.toggle, "DAP REPL")
map("<leader>dl", dap.run_last, "DAP Run Last")
map("<leader>du", dv.toggle, "DAP View Toggle")
-- stylua: ignore end
