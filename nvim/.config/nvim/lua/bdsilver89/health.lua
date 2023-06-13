local M = {}

local health = {
  start = vim.health.start or vim.health.report_start,
  ok = vim.health.ok or vim.health.report_ok,
  warn = vim.health.warn or vim.health.report_warn,
  error = vim.health.error or vim.health.report_error,
  info = vim.health.info or vim.health.report_info,
}

function M.check()
  health.start("bdsilver89")

  if vim.version().prerelease then
    health.warn("Neovim nightly not fully supported and may introduce breaking changes")
  elseif vim.fn.has("nvim-0.8") == 1 then
    health.ok("Using Neovim >= 0.8")
  else
    health.error("Neovim >= 0.8 is required")
  end

  local programs = {
    -- stylua: ignore
    { cmd = "git", type = "error", msg = "Used for core functionality and plugin management" },
    { cmd = "rg", type = "warn", msg = "Used for grep replacement" },
    { cmd = "fzf", type = "warn", msg = "Used for fuzzy searches" },
    { cmd = { "fd", "fdfind" }, type = "warn", msg = "Used for find replacement" },
    { cmd = "lazygit", type = "warn", msg = "Used for git TUI" },
    { cmd = "node", type = "warn", msg = "Used for some LSP servers" },
    { cmd = { "python", "python3" }, type = "warn", msg = "Used for some LSP servers" },
    {
      cmd = { "xdg-open", "open", "explorer" },
      type = "warn",
      msg = "Used for opening files with system opener",
    },
  }

  for _, program in ipairs(programs) do
    local commands = type(program.cmd) == "string" and { program.cmd } or program.cmd
    ---@cast commands string[]

    local name = table.concat(commands, "/")
    local found = false
    for _, cmd in ipairs(commands) do
      if vim.fn.executable(cmd) == 1 then
        name = cmd
        found = true
        break
      end
    end

    if found then
      health.ok(("`%s` is installed: %s"):format(name, program.msg))
    else
      health.warn(("`%s` is not installed: %s"):format(name, program.msg))
    end
  end
end

return M