local function jdtls_client()
  return vim.lsp.get_clients({ name = "jdtls" })[1]
end

local function execute_command(cmd, callback)
  local client = jdtls_client()
  if not client then
    vim.notify("jdtls is not attached", vim.log.levels.ERROR)
    callback("jdtls not attached", nil)
    return
  end
  client:request("workspace/executeCommand", cmd, function(err, result)
    callback(err, result)
  end)
end

local function co_execute(cmd)
  local co = coroutine.running()
  execute_command(cmd, function(err, result)
    coroutine.resume(co, err, result)
  end)
  return coroutine.yield()
end

local selected_main

local function pick_main_class()
  local err, mains = co_execute({ command = "vscode.java.resolveMainClass" })
  if err or not mains or #mains == 0 then
    vim.notify("No main class found", vim.log.levels.ERROR)
    return nil
  end
  if #mains == 1 then
    return mains[1]
  end
  local co = coroutine.running()
  vim.ui.select(mains, {
    prompt = "Select main class",
    format_item = function(m)
      return m.mainClass .. " (" .. (m.projectName or "") .. ")"
    end,
  }, function(choice)
    coroutine.resume(co, choice)
  end)
  return coroutine.yield()
end

return {
  adapter = function(callback)
    execute_command({ command = "vscode.java.startDebugSession" }, function(err, port)
      if err then
        vim.notify("Failed to start debug session: " .. vim.inspect(err), vim.log.levels.ERROR)
        return
      end
      callback({ type = "server", host = "127.0.0.1", port = port })
    end)
  end,
  filetypes = { "java" },
  configurations = {
    {
      name = "Launch main class",
      type = "java",
      request = "launch",
      mainClass = function()
        selected_main = pick_main_class()
        return selected_main and selected_main.mainClass or nil
      end,
      projectName = function()
        return selected_main and selected_main.projectName or ""
      end,
      modulePaths = function()
        if not selected_main then return {} end
        local err, paths = co_execute({
          command = "vscode.java.resolveClasspath",
          arguments = { selected_main.mainClass, selected_main.projectName },
        })
        if err or not paths then return {} end
        return paths[1] or {}
      end,
      classPaths = function()
        if not selected_main then return {} end
        local err, paths = co_execute({
          command = "vscode.java.resolveClasspath",
          arguments = { selected_main.mainClass, selected_main.projectName },
        })
        if err or not paths then return {} end
        return paths[2] or {}
      end,
      cwd = "${workspaceFolder}",
      console = "integratedTerminal",
    },
    {
      name = "Attach to remote JVM",
      type = "java",
      request = "attach",
      hostName = function()
        return vim.fn.input("Host: ", "127.0.0.1")
      end,
      port = function()
        return tonumber(vim.fn.input("Port: ", "5005"))
      end,
    },
  },
}
