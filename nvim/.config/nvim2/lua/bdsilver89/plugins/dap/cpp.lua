local dap = require("dap")

dap.adapters.codelldb = {
  type = "server",
  port = "${port}",
  executable = {
    command = vim.fn.stdpath("data") .. "/mason/bin/codelldb",
    args = { "--port", "${port}" },
  },
}

dap.adapters.cpp = {
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
