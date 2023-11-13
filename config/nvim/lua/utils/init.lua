local M = {}

setmetatable(M, {
  __index = function(t, k)
    t[k] = require("utils." .. k)
    return t[k]
  end,
})

---@param name string
function M.has(name)
  local lazy_avail, lazy = pcall(require, "lazy.core.config")
  return lazy_avail and lazy.spec.plugins[name] ~= nil
end

---@param name string
function M.opts(name)
  local plugin = require("lazy.core.config").plugins[name]
  if not plugin then
    return {}
  end
  local Plugin = require("lazy.core.plugin")
  return Plugin.values(plugin, "opts", false)
end

---@param name string
---@param fn fun(name:string)
function M.on_load(name, fn)
  local Config = require("lazy.core.config")
  if Config.plugins[name] and Config.plugins[name]._.loaded then
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

function M.get_upvalue(fn, name)
  local i = 1
  while true do
    local n,v = debug.getupvalue(fn, i)
    if not n then
      break
    end
    if n == name then
      return v
    end
    i = i + 1
  end
end

return M
