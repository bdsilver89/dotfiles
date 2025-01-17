local M = {}

function M.get_plugin(name)
  return require("lazy.core.config").spec.plugins[name]
end

function M.has_plugin(name)
  return M.get_plugin(name) ~= nil
end

function M.plugin_opts(name)
  local plugin = M.get_plugin(name)
  if not plugin then
    return {}
  end
  return require("lazy.core.plugin").values(plugin, "opts", false)
end

function M.get_package_path(package, path, opts)
  pcall(require, "mason")
  local root = vim.env.MASON or (vim.fn.stdpath("data") .. "/mason")
  opts = opts or {}
  opts.warn = opts.warn == nil and true or opts.warn
  path = path or ""
  local ret = root .. "/packages/" .. package .. "/" .. path
  if opts.warn and not vim.uv.fs_stat(ret) and not require("lazy.core.config").headless() then
    vim.notify(
      ("Mason package path not found for **%s**:\n- `%s`\nYou may need to force update the package."):format(
        package,
        path
      ),
      vim.log.levels.WARN,
      { title = "Config" }
    )
  end
  return ret
end

function M.is_loaded(name)
  local Config = require("lazy.core.config")
  return Config.plugins[name] and Config.plugins[name]._.loaded
end

function M.on_load(name, callback)
  if M.is_loaded(name) then
    callback(name)
  else
    vim.api.nvim_create_autocmd("User", {
      pattern = "LazyLoad",
      callback = function(event)
        if event.data == name then
          callback(name)
          return true
        end
      end,
    })
  end
end

return M
