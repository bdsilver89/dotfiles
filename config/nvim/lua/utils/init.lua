local M = {}

setmetatable(M, {
  __index = function(t, k)
    t[k] = require("utils." .. k)
    return t[k]
  end,
})

function M.lazy_keymap(keymaps, buffer)
  local Keys = require("lazy.core.handler.keys")
  for _, keys in pairs(Keys.resolve(keymaps)) do
    local opts = Keys.opts(keys)
    ---@diagnostic disable-next-line: inject-field
    opts.silent = opts.silent ~= false

    if buffer ~= nil then
      ---@diagnostic disable-next-line: inject-field
      opts.buffer = buffer
    end

    ---@diagnostic disable-next-line: param-type-mismatch
    vim.keymap.set(keys.mode or "n", keys.lhs, keys.rhs, opts)
  end
end

function M.get_pkg_path(pkg, path, opts)
  pcall(require, "mason")
  local root = vim.env.MASON or (vim.fn.stdpath("data") .. "/mason")
  opts = opts or {}
  opts.warn = opts.warn == nil and true or opts.warn
  path = path or ""
  local ret = root .. "/packages/" .. pkg .. "/" .. path
  if opts.warn and not vim.loop.fs_stat(ret) and not require("lazy.core.config").headless() then
    vim.notify(
      ("Mason package path not found for **%s**:\n- `%s`\nYou may need to force update the package."):format(pkg, path),
      vim.log.levels.WARN
    )
  end
  return ret
end

return M
