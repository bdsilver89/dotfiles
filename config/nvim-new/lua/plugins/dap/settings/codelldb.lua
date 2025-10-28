local dap = require("dap")
local extension_path = table.concat({
  vim.fn.stdpath("data"),
  "mason",
  "packages",
  "codelldb",
  "extension",
}, vim.g.path_delimiter)

local codelldb_path = table.concat({
  extension_path,
  "adapter",
  "codelldb",
}, vim.g.path_delimiter)

dap.adapters.codelldb = {
  type = "server",
  port = "${port}",
  executable = {
    command = codelldb_path,
    args = { "--port", "${port}" },
  },
}

dap.configurations.cpp = {
  {
    name = "Launch file",
    type = "codelldb",
    request = "launch",
    prorgram = function()
      return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
    end,
    cwd = "${workspaceFolder}",
    stopOnEntry = true,
  },
}

dap.configurations.c = dap.configurations.cpp
