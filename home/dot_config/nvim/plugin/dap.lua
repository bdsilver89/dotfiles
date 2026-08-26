local add_on_event = require("pack").add_on_event

local arrows = require("icons").arrows

local icons = {
  Stopped = { "", "DiagnosticWarn", "DapStoppedLine" },
  Breakpoint = "",
  BreakpointCondition = "",
  BreakpointRejected = { "", "DiagnosticError" },
  LogPoint = arrows.right,
}
for name, sign in pairs(icons) do
  sign = type(sign) == "table" and sign or { sign }
  vim.fn.sign_define("Dap" .. name, {
    -- stylua: ignore
    text = sign[1] --[[@as string]] .. ' ',
    texthl = sign[2] or "DiagnosticInfo",
    linehl = sign[3],
    numhl = sign[3],
  })
end

add_on_event({ "BufReadPost", "BufNewFile" }, {
  {
    src = "theHamsta/nvim-dap-virtual-text",
  },
  {
    src = "igorlfs/nvim-dap-view",
    module_name = "dap-view",
  },
  {
    src = "mfussenegger/nvim-dap-python",
    setup = false,
    on_setup = function()
      local install_path = require("mason-registry").get_package("debugpy"):get_install_path()
      require("dap-python").setup(install_path .. "/venv/bin/python")
    end,
  },
  {
    src = "mfussenegger/nvim-dap",
    setup = false,
    on_setup = function()
      vim.keymap.set("n", "<leader>db", function()
        require("dap").toggle_breakpoint()
      end, { desc = "Toggle breakpoint" })
      vim.keymap.set("n", "<leader>dB", "<cmd>FzfLua dap_breakpoints<cr>", { desc = "List breakpoints" })
      vim.keymap.set("n", "<leader>dc", function()
        require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
      end, { desc = "Conditional breakpoint" })
      vim.keymap.set("n", "<F5>", function()
        require("dap").continue()
      end, { desc = "Continue" })
      vim.keymap.set("n", "<F10>", function()
        require("dap").step_over()
      end, { desc = "Step over" })
      vim.keymap.set("n", "<F11>", function()
        require("dap").step_into()
      end, { desc = "Step into" })
      vim.keymap.set("n", "<F12>", function()
        require("dap").step_out()
      end, { desc = "Step out" })

      local dap = require("dap")
      local dv = require("dap-view")

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("dapopts", { clear = true }),
        pattern = "dap-view",
        callback = function()
          vim.wo[0][0].listchars = "space: ,tab:   "
        end,
      })

      dap.listeners.before.attach["dap-view-config"] = function()
        dv.open()
      end
      dap.listeners.before.launch["dap-view-config"] = function()
        dv.open()
      end
      dap.listeners.after.event_terminated["dap-view-config"] = function()
        dv.close()
      end
      dap.listeners.after.event_exited["dap-view-config"] = function()
        dv.close()
      end

      dap.adapters.codelldb = {
        type = "server",
        host = "127.0.0.1",
        port = "${port}",
        executable = {
          command = "codelldb",
          args = { "--port", "${port}" },
        },
      }

      for _, lang in ipairs({ "c", "cpp" }) do
        dap.configurations[lang] = {
          {
            type = "codelldb",
            request = "launch",
            name = "Launch file",
            program = function()
              return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
            end,
            cwd = "${workspaceFolder}",
          },
          {
            type = "codelldb",
            request = "attach",
            name = "Attach to process",
            pid = require("dap.utils").pick_process,
            cwd = "${workspaceFolder}",
          },
        }
      end
    end,
  },
})
