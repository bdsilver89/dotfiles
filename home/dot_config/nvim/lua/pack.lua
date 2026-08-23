local M = {}

---@class PluginSpec
---@field src string
---@field module_name? string
---@field opts? table|fun():table
---@field on_setup? fun()|nil
---@field setup? false

---@param plugins PluginSpec[]
local function init(plugins)
  local sources = vim
    .iter(plugins)
    :map(function(plugin)
      return string.format("https://github.com/%s", plugin.src)
    end)
    :totable()

  vim.pack.add(sources)
end

---@param plugins PluginSpec[]
local function configure(plugins)
  for _, plugin in ipairs(plugins) do
    if plugin.setup ~= false then
      local module_name = plugin.module_name or (plugin.src:match(".+/(.+)"):gsub("%.nvim$", ""))
      local mod = require(module_name)
      if type(mod.setup) == "function" then
        local opts = type(plugin.opts) == "function" and plugin.opts() or plugin.opts
        mod.setup(opts or {})
      end
    end

    if plugin.on_setup then
      plugin.on_setup()
    end
  end
end

---@param event vim.api.keyset.events|vim.api.keyset.events[]
---@param pattern? string|string[]
---@param plugins PluginSpec[]
local function add_on_event(event, pattern, plugins)
  init(plugins)
  vim.api.nvim_create_autocmd(event, {
    pattern = pattern,
    once = true,
    callback = function()
      configure(plugins)
    end,
  })
end

---@param plugins PluginSpec[]
function M.add(plugins)
  init(plugins)
  configure(plugins)
end

---@param event vim.api.keyset.events|vim.api.keyset.events[]
---@param plugins PluginSpec[]
function M.add_on_event(event, plugins)
  add_on_event(event, nil, plugins)
end

---@param patterns string|string[]
---@param plugins PluginSpec[]
function M.add_on_filetype(patterns, plugins)
  add_on_event("FileType", patterns, plugins)
end

---@param plugin_name string
---@param cmd string|fun():nil
function M.on_plugin_update(plugin_name, cmd)
  vim.api.nvim_create_autocmd("PackChanged", {
    callback = function(ev)
      if ev.data.spec.name == plugin_name and (ev.data.kind == "install" or ev.data.kind == "update") then
        if type(cmd) == "string" then
          vim.system({ cmd }, { cwd = ev.data.path })
        else
          cmd()
        end
      end
    end,
  })
end

return M
