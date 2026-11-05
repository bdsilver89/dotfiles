local dv = require("dap-view")
dv.setup({})

local dap = require("dap")
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

-- debugpy for python
dap.adapters.python = {
  type = "executable",
  command = "debugpy-adapter",
}
dap.configurations.python = {
  {
    name = "Python: current file",
    type = "python",
    request = "launch",
    program = "${file}",
    cwd = "${workspaceFolder}",
    console = "integratedTerminal",
    pythonPath = function()
      if vim.env.VIRTUAL_ENV then
        return vim.fs.joinpath(vim.env.VIRTUAL_ENV, "bin", "python")
      end

      local python
      vim.fs.joinpath(vim.fn.getcwd(), ".venv", "bin", "python")
      if vim.fn.executable(python) == 1 then
        return python
      end

      return vim.fn.exepath("python")
    end,
  },
}

-- codelldb for c/c++/rust
dap.adapters.codelldb = {
  type = "server",
  port = "${port}",
  executable = {
    command = "codelldb",
    args = { "--port", "${port}" },
  },
}
for _, filetype in ipairs({ "c", "cpp", "rust" }) do
  local executable_dir = filetype == "rust" and "/target/debug" or "/"

  dap.configurations[filetype] = {
    {
      name = "CodeLLDB: launch executable",
      type = "codelldb",
      request = "launch",
      program = function()
        return vim.fn.input({
          prompt = "Executable: ",
          default = vim.fn.getcwd() .. executable_dir,
          completion = "file",
        })
      end,
      cwd = "${workspaceFolder}",
      stopOnEntry = true,
      args = {},
    },
    {
      name = "CodeLLDB: attach to process",
      type = "codelldb",
      request = "attach",
      pid = require("dap.utils").pick_progrss,
      cwd = "${workspaceFolder}",
    },
  }
end

-- pwa node
dap.adapters["pwa-node"] = function(callback)
  local result = vim
    .system({
      "mise",
      "where",
      "github:microsfot/vscode-js-debug",
    }, { text = true })
    :wait()

  if result.code ~= 0 then
    vim.notify("Cannot locate vscode-js-debug: " .. (result.stderr or ""), vim.log.levels.WARN)
    return
  end

  local server = vim.fs.joinpath(vim.trim(result.stdout), "src", "dapDebugServer.js")

  if vim.fn.filereadable(server) ~= 1 then
    vim.notify("Cannot locate vscode-js-debug: " .. server, vim.log.levels.WARN)
    return
  end

  callback({
    type = "server",
    host = "127.0.0.1",
    port = "${port}",
    executable = {
      command = "node",
      args = { server, "${port}" },
    },
  })
end
for _, filetype in ipairs({ "javascript", "typescript" }) do
  dap.configurations[filetype] = {
    {
      name = "Node: launch current file",
      type = "pwa-node",
      request = "launch",
      runtimeExectuable = "node",
      program = "${file}",
      cwd = "${workspaceFolder}",
      console = "integratedTerminal",
      sourceMaps = true,
      skipFiles = { "<node_internals>/**" },
    },
    {
      name = "Node: attach on port 9229",
      type = "pwa-node",
      request = "attach",
      address = "127.0.0.1",
      port = 9229,
      cwd = "${workspaceFolder}",
      sourceMaps = true,
      skipFiles = { "<node_internals>/**" },
    },
  }
end

-- java
dap.adapters.java = function(callback)
  local bufnr = vim.api.nvim_get_current_buf()
  local client = vim.lsp.get_clients({
    name = "jdtls",
    bufnr = bufnr,
  })[1]

  if not client then
    vim.notify("JDTLS is not attached to this buffer", vim.log.levels.WARN)
    return
  end

  local sent = client:request("workspace/executeCommand", {
    command = "vscode.java.startDebugSession",
  }, function(err, port)
    if err then
      vim.notify("Java debug adapter failed: " .. vim.inspect(err), vim.log.levels.ERROR)
      return
    end

    if type(port) ~= "number" then
      vim.notify("JDTLS returned no java debug port", vim.log.levels.ERROR)
      return
    end

    callback({
      type = "server",
      host = "127.0.0.1",
      port = port,
    })
  end, bufnr)

  if not sent then
    vim.notify("Could not send java debug request", vim.log.levels.ERROR)
  end
end
dap.configurations.java = {
  {
    name = "Java: launch main class",
    type = "java",
    request = "launch",
    mainClass = function()
      vim.fn.input("Main class: ")
    end,
    cwd = "${workspaceFolder}",
    console = "integratedTerminal",
  },
  {
    name = "Java: attach on port 5005",
    type = "java",
    request = "attach",
    hostName = "127.0.0.1",
    port = 5005,
  },
}
