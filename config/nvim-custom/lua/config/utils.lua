local M = {}

---@class config.Toggle
---@field name string
---@field get fun():boolean
---@field set fun(state:boolean)
---@overload fun()

---@param lhs string
---@param info config.Toggle
function M.toggle(lhs, info)
  vim.keymap.set("n", lhs, function()
    local state = not info.get()
    info.set(state)
    if state then
      vim.notify("Enabled " .. info.name, vim.log.levels.INFO, { title = info.name })
    else
      vim.notify("Disabled " .. info.name, vim.log.levels.WARN, { title = info.name })
    end
  end, { desc = "Toggle " .. info.name })

  if M.has_plugin("which-key.nvim") then
    require("which-key").add({
      {
        lhs,
        icon = function()
          if not vim.g.enable_icons then
            return {}
          end
          return info.get() and { icon = " ", color = "green" } or { icon = " ", color = "yellow" }
        end,
        desc = function()
          return (info.get() and "Disable " or "Enable ") .. info.name
        end,
      },
    })
  end
end

---@param name string
function M.get_plugin(name)
  return require("lazy.core.config").spec.plugins[name]
end

---@param name string
function M.has_plugin(name)
  return M.get_plugin(name) ~= nil
end

---@param name string
function M.opts(name)
  local plugin = M.get_plugin(name)
  if not plugin then
    return {}
  end
  return require("lazy.core.plugin").values(plugin, "opts", false)
end

---@param uri string
---@param opts { system?:boolean}
function M.open(uri, opts)
  opts = opts or {}
  if not opts.system and vim.uv.fs_stat(uri) ~= nil then
    -- TODO: display file in float toggleterm
  end

  local Config = require("lazy.core.config")
  local cmd
  if not opts.system and Config.options.ui.browser then
    cmd = { Config.options.ui.browser, uri }
  elseif vim.fn.has("win32") == 1 then
    cmd = { "explorer", uri }
  elseif vim.fn.has("macunix") == 1 then
    cmd = { "open", uri }
  else
    if vim.fn.executable("explorer.exe") == 1 then
      cmd = { "explorer.exe", uri }
    elseif vim.fn.executable("xdg-open") == 1 then
      cmd = { "xdg-open", uri }
    else
      cmd = { "open", uri }
    end
  end

  local ret = vim.fn.jobstart(cmd, { detach = true })
  if ret <= 0 then
    local msg = {
      "Failed to open uri",
      ret,
      vim.inspect(cmd),
    }
    vim.notify(table.concat(msg, "\n"), vim.log.levels.ERROR)
  end
end

return M
