local debugpy_python = vim.fn.expand("$MASON/packages/debugpy/venv/bin/python")

local function project_python()
  local venv = os.getenv("VIRTUAL_ENV")
  if venv and venv ~= "" then
    return venv .. "/bin/python"
  end
  for _, dir in ipairs({ ".venv", "venv" }) do
    local candidate = vim.fn.getcwd() .. "/" .. dir .. "/bin/python"
    if vim.fn.executable(candidate) == 1 then
      return candidate
    end
  end
  return vim.fn.exepath("python3") ~= "" and "python3" or "python"
end

return {
  adapter = {
    type = "executable",
    command = debugpy_python,
    args = { "-m", "debugpy.adapter" },
  },
  filetypes = { "python" },
  configurations = {
    {
      name = "Launch current file",
      type = "python",
      request = "launch",
      program = "${file}",
      cwd = "${workspaceFolder}",
      console = "integratedTerminal",
      pythonPath = project_python,
      justMyCode = false,
    },
    {
      name = "Launch module",
      type = "python",
      request = "launch",
      module = function()
        return vim.fn.input("Module: ")
      end,
      cwd = "${workspaceFolder}",
      console = "integratedTerminal",
      pythonPath = project_python,
      justMyCode = false,
    },
    {
      name = "Attach (remote)",
      type = "python",
      request = "attach",
      connect = function()
        return {
          host = vim.fn.input("Host: ", "127.0.0.1"),
          port = tonumber(vim.fn.input("Port: ", "5678")),
        }
      end,
    },
  },
}
