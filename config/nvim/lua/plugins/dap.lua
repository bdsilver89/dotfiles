vim.pack.add({
  "https://github.com/mfussenegger/nvim-dap",
  "https://github.com/igorlfs/nvim-dap-view",
  "https://github.com/theHamsta/nvim-dap-virtual-text",
})

local dap_initialized = false

local function init_dap()
  if dap_initialized then
    return
  end

  dap_initialized = true

  local dap = require("dap")
  local dap_view = require("dap-view")

  dap.listeners.after.event_initailized.dapview_config = function()
    dap_view.open()
  end
  dap.listeners.before.event_terminated.dapview_config = function()
    dap_view.close()
  end
  dap.listeners.before.event_exited.dapview_config = function()
    dap_view.close()
  end
end


-- stylua: ignore start
vim.keymap.set("n", "<leader>db", function() init_dap(); require("dap").toggle_breakpoint() end, { desc = "Toggle breakpoint" })
-- stylua: ignore end
