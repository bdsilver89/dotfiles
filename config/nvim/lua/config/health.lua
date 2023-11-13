local M = {}

local health = {
  start = vim.health.start or vim.health.report_start,
  ok = vim.health.ok or vim.health.report_ok,
  warn = vim.health.warn or vim.health.report_warn,
  error = vim.health.error or vim.health.report_error,
  info = vim.health.info or vim.health.report_info,
}

function M.check()
  health.start("bdsilver89 config")
  health.info("Neovim version: v" .. vim.fn.matchstr(vim.fn.execute("version"), "NVIM v\\zs[^\n]*"))

  if vim.version().prerelease then
    health.warn("Neovim nightly may have breaking changes")
  elseif vim.fn.has("nvim-0.9") == 1 then
    health.ok("Using stable Neovim 0.9")
  else
    health.error("Neovim >= 0.9.0 is required")
  end

  local programs = {
    {
      cmd = { "git" },
      type = "error",
      msg = "Used for core functionality and plugin management",
    },
    {
      cmd = { "lazygit" },
      type = "warn",
      msg = "Used for mappings to pull up git TUI",
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
      health.ok(("`%s` is installed: %s"):format(name, program.msg))
    else
      health[program.type](("`%s` is not installed: %s"):format(name, program.msg))
    end
  end
end

return M
