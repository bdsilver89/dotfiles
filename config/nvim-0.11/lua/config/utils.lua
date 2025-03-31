local M = {}

---@param name string
function M.get_plugin(name)
  return require("lazy.core.config").spec.plugins[name]
end

---@param name string
function M.opts(name)
  local plugin = M.get_plugin(name)
  if not plugin then
    return {}
  end
  local Plugin = require("lazy.core.plugin")
  return Plugin.values(plugin, "opts", false)
end

---@param name string
function M.is_loaded(name)
  local Config = require("lazy.core.config")
  return Config.plugins[name] and Config.plugins[name]._.loaded
end

---@param name string
---@param fn fun(name:string)
function M.on_load(name, fn)
  if M.is_loaded(name) then
    fn(name)
  else
    vim.api.nvim_create_autocmd("User", {
      pattern = "LazyLoad",
      callback = function(event)
        if event.data == name then
          fn(name)
          return true
        end
      end,
    })
  end
end

function M.toggle(name, getter, setter)
  local state = not getter()
  vim.notify(
    (state and "Enabled" or "Disabled") .. " **" .. name .. "**",
    state and vim.log.levels.INFO or vim.log.levels.WARN
  )
  setter(state)
end

function M.toggle_option(name, option)
  M.toggle(name, function()
    return vim.opt[option]:get()
  end, function(state)
    vim.opt[option] = state
  end)
end

return M
