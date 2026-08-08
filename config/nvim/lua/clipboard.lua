-- Setting vim.g.clipboard explicitly skips the provider's executable() probing,
-- which costs ~480ms under WSL where $PATH spans the 9p mount.

local M = {}

local function is_remote()
  return (vim.env.SSH_TTY or vim.env.SSH_CONNECTION or vim.env.SSH_CLIENT) ~= nil
end

local function is_wsl()
  if vim.env.WSL_DISTRO_NAME or vim.env.WSL_INTEROP then
    return true
  end
  local ok, release = pcall(vim.fn.readfile, "/proc/sys/kernel/osrelease")
  return ok and release[1] ~= nil and release[1]:lower():find("microsoft") ~= nil
end

local function last_yank()
  return vim.fn.getreg('"', 1, true)
end

local function osc52()
  local osc = require("vim.ui.clipboard.osc52")
  return {
    name = "OSC 52",
    copy = { ["+"] = osc.copy("+"), ["*"] = osc.copy("*") },
    -- Not osc.paste: it blocks 1s then 9s more waiting for a terminal reply
    -- most refuse, so every "+p hangs. Terminal paste bypasses this anyway.
    paste = { ["+"] = last_yank, ["*"] = last_yank },
  }
end

local function wsl()
  -- Resolved once: exec-time PATH lookup costs 51ms per copy against 31ms.
  local yank = vim.fn.exepath("win32yank.exe")
  if yank ~= "" then
    return {
      name = "win32yank",
      copy = { ["+"] = { yank, "-i", "--crlf" }, ["*"] = { yank, "-i", "--crlf" } },
      paste = { ["+"] = { yank, "-o", "--lf" }, ["*"] = { yank, "-o", "--lf" } },
      cache_enabled = false,
    }
  end

  local paste = "powershell.exe -NoLogo -NoProfile -NonInteractive -Command "
    .. '[Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))'
  return {
    name = "clip.exe",
    copy = { ["+"] = { "clip.exe" }, ["*"] = { "clip.exe" } },
    paste = { ["+"] = paste, ["*"] = paste },
    cache_enabled = false,
  }
end

function M.setup()
  -- Remote first: sshing into a Mac or WSL box should land text on the machine
  -- you are typing at. has("win32") is 0 under WSL and cannot detect it.
  if is_remote() then
    vim.g.clipboard = osc52()
  elseif vim.fn.has("mac") == 1 then
    vim.g.clipboard = "pbcopy"
  elseif is_wsl() then
    vim.g.clipboard = wsl()
  end
  -- Linux falls through: autodetect is correct and cheap there.

  vim.o.clipboard = "unnamedplus"
end

return M
