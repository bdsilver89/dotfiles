local M = {}

function M.check()
  vim.health.start("bdsilver89 Configuation")

  if vim.fn.has("nvim-0.9") == 1 then
    vim.health.ok("Using Neovim >= 0.9")
  else
    vim.health.error("Neovim >= 0.9 is required")
  end

  local programs = {
    {
      cmd = { "git" },
      type = "error",
      msg = "Used for core functionality such as plugin management",
    },
    {
      cmd = { "rg" },
      type = "warn",
      msg = "Used for improved grep",
    },
    {
      cmd = { "fd", "fdfind" },
      type = "warn",
      msg = "Used for file searching",
    },
    {
      cmd = { "xdg-open", "rundll32", "explorer.exe", "open" },
      type = "warn",
      msg = "Used for mapping opening files with system file explorer",
    },
    {
      cmd = { "lazygit" },
      type = "warn",
      msg = "Used for git TUI",
    },
    {
      cmd = { "node" },
      type = "warn",
      msg = "Used for node REPL",
    },
    {
      cmd = { "python", "python3" },
      type = "warn",
      msg = "Used for python REPL",
    },
  }

  for _, program in ipairs(programs) do
    local name = table.concat(program.cmd, "/")
    local found = false
    for _, cmd in ipairs(program.cmd) do
      if vim.fn.executable(cmd) == 1 then
        name = cmd
        if not program.extra_check or program.extra_check(program) then
          found = true
        end
        break
      end
    end

    if found then
      vim.health.ok(("'%s' is installed: %s"):format(name, program.msg))
    else
      vim.health[program.type](("'%s' is not installed: %s"):format(name, program.msg))
    end
  end
end

return M
