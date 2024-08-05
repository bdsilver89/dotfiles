return {
  check = function()
    vim.health.start("PDE")

    vim.health.info("System information: " .. vim.inspect(vim.uv.os_uname()))

    -- version
    local verstr = tostring(vim.version())
    if not vim.version.ge then
      vim.health.error(string.format("Neovim out of date: '%s'. Upgrade to latest stable or nightly", verstr))
    end

    if vim.version.ge(vim.version(), "0.10-dev") then
      vim.health.ok(string.format("Neovim version: '%s'", verstr))
    else
      vim.health.error(string.format("Neovim out of date: '%s'. Upgrade to latest stable or nightly", verstr))
    end

    -- external deps
    local programs = {
      {
        cmd = { "git" },
        type = "error",
        msg = "Used for core functionality",
      },
      {
        cmd = { "rg" },
        type = "warn",
        msg = "Used for Telescope live grep",
      },
      {
        cmd = { "lazygit" },
        type = "warn",
        msg = "Used for TUI git interface",
      },
      {
        cmd = { "node" },
        type = "warn",
        msg = "Used for terminal REPL and some LSP servers",
      },
      {
        cmd = { "python", "python3" },
        type = "warn",
        msg = "Used for terminal REPL and some LSP servers",
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
  end,
}
