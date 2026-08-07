local pack = require("pack")

pack.add_on_cmd({
  "Mason",
  "MasonInstall",
  "MasonUninstall",
  "MasonUpdate",
  "MasonLog",
},
{
  { src = "mason-org/mason.nvim" },
})


local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"

-- Mason only prepends its bin dir to PATH during setup, which is lazy, so do it
-- here: tools Mason already installed have to be spawnable without paying to
-- load the plugin. Harmless before the dir exists, and it means binaries are
-- reachable the moment an install drops them in.
vim.env.PATH = mason_bin .. ":" .. vim.env.PATH

local M = {}

---@class Tool
---@field bin string
---@field lang string
---@field install? string[]
---@field mason? string

---@type Tool[]
-- stylua: ignore start
M.tools = {
  { bin = "rust-analyzer", lang = "rust", mason = "rust-analyzer" },

  { bin = "lua-language-server", lang = "lua", mason = "lua-language-server" },
  { bin = "stylua", lang = "lua", mason = "stylua" },
}
-- stylua: ignore end

---@param tool Tool
---@return boolean
local function is_mason_owned(tool)
  return vim.uv.fs_stat(mason_bin .. "/" .. tool.bin) ~= nil
end

---@param tool Tool
---@return boolean
local function is_missing(tool)
  return vim.fn.executable(tool.bin) == 0
end

---@return Tool[]
function M.missing()
  return vim.iter(M.tools):filter(is_missing):totable()
end

---@return Tool[]
function M.syncable()
  return vim.iter(M.tools)
    :filter(function(t)
      return is_missing(t) or is_mason_owned(t)
    end)
    :totable()
end

---@param mason_name string
local function reattach(mason_name)
  local tool = vim.iter(M.tools):find(function(t)
    return t.mason == mason_name
  end)
  if tool == nil or tool.lsp == nil then
    return
  end
  -- The FileType that would have started this LSP fired before the binary
  -- existed, so replay it on the buffers that missed out.
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].filetype == tool.lang then
      vim.api.nvim_exec_autocmds("FileType", { buffer = buf, modeline = false })
    end
  end
end

local listening = false

-- :MasonInstall returns as soon as the downloads are queued, so anything that
-- needs the binaries has to wait for the registry rather than the command.
local function on_install_success()
  if listening then
    return
  end
  local ok, registry = pcall(require, "mason-registry")
  if not ok then
    return
  end
  listening = true
  registry:on(
    "package:install:success",
    vim.schedule_wrap(function(pkg)
      reattach(pkg.name)
    end)
  )
end

---@param missing Tool[]
function M.install(missing)
  local pkgs = vim.tbl_map(function(t)
    return t.mason
  end, missing)
  if #pkgs == 0 then
    return
  end
  vim.cmd("MasonInstall " .. table.concat(pkgs, " "))
  on_install_success()
end

vim.api.nvim_create_user_command("ToolSync", function(args)
  local missing = M.missing()

  if not args.bang then
    if #missing == 0 then
      vim.notify(("All %d tools present, :ToolSync! to update"):format(#M.tools))
    else
      local names = vim.tbl_map(function(t) return t.bin end, missing)
      vim.notify(
        ("%d missing %s\nRun :ToolSync! to install"):format(#missing, table.concat(names, ", ")),
        vim.log.levels.WARN
      )
    end
    return
  end

  local targets = M.syncable()
  if #targets == 0 then
    vim.notify("Nothing to sync")
    return
  end

  vim.cmd("MasonUpdate")
  M.install(missing)
end, {
  bang = true,
  desc = "Report missing external tools, :ToolSync! updates and installs them",
})

vim.api.nvim_create_autocmd("VimEnter", {
  group = vim.api.nvim_create_augroup("config_tools", { clear = true }),
  once = true,
  callback = function()
    if #vim.api.nvim_list_uis() == 0 then
      return
    end
    vim.schedule(function()
      local missing = M.missing()
      if #missing > 0 then
        vim.notify(("Installing %d missing tools"):format(#missing))
        M.install(missing)
      end
    end)
  end,
})

return M
