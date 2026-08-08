-- Under WSL every executable() miss walks ~39 Windows $PATH entries behind the
-- 9p mount. Hiding them during config load took rustaceanvim's four probes for
-- optional tools from 357ms to 0.1ms.

local M = {}

local function is_wsl()
  if vim.env.WSL_DISTRO_NAME or vim.env.WSL_INTEROP then
    return true
  end
  local ok, release = pcall(vim.fn.readfile, "/proc/sys/kernel/osrelease")
  return ok and release[1] ~= nil and release[1]:lower():find("microsoft") ~= nil
end

--- Run `fn` with Windows entries hidden from $PATH, then restore it so
--- :terminal and :! can still reach them. Anything needing a Windows binary
--- must resolve it before this runs -- clipboard.lua does.
function M.without_windows(fn)
  if not is_wsl() then
    return fn()
  end

  local original = vim.env.PATH
  vim.env.PATH = table.concat(
    vim.iter(vim.split(original, ":"))
      :filter(function(entry)
        return not entry:match("^/mnt/%a/")
      end)
      :totable(),
    ":"
  )

  local ok, err = pcall(fn)
  vim.env.PATH = original

  if not ok then
    error(err, 0)
  end
end

return M
