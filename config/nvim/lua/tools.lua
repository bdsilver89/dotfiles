local pack = require("pack")

pack.add_on_cmd({
  "Mason",
  "MasonInstall",
  "MasonUninstall",
  "MasonUpdate",
  "MasonLog",
},
{
  { src = "mason-org/mason.nvim", setup = false },
})


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

local function is_missing(tool)
  return vim.fn.executable(tool.bin) == 0
end

---@param tool Tool
---@return boolean
function is_mason_owned(tool)
  return vim.uv.fs_stat(vim.fn.stdpath("data") .. "/mason/bin/" .. tool.bin) ~= nil
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

---@param missing Tool[]
function M.install(missing)
  local pkgs = vim.tbl_map(function(t)
    return t.mason
  end, missing)
  vim.cmd("MasonInstall " .. table.concat(pkgs, " "))
end

vim.api.nvim_create_user_command("ToolSync", function(args)
  local missing = M.missing()

  if not args.bang then
    if #missing == 0 then
      vim.notify(("All %d tools present, :ToolSync! to update"):format(#M.tools))
    else
      local names = vim.tbl_map(function(t) return t.bind end, missing)
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
