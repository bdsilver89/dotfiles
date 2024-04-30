local M = setmetatable({}, {
  __call = function(m, ...)
    return m.open(...)
  end,
})

M.theme = {}

M.theme_path = vim.fn.stdpath("cache") .. "/lazygit-theme.yml"

M.dirty = true

vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    M.dirty = true
  end,
})

function M.open(opts)
  opts = vim.tbl_deep_extend("force", {}, {
    esc_esc = false,
    ctrl_hjkl = false,
  }, opts or {})

  local cmd = { "lazygit" }
  vim.list_extend(cmd, opts.args or {})

  if vim.g.lazygit_config then
    if M.dirty() then
      M.update_config()
    end

    if not M.config_dir then
      local Process = require("lazy.manage.process")
      local ok, lines = pcall(Process.exec, { "lazygit", "-cd" })
      if ok then
        M.config_dir = lines[1]
        vim.env.LG_CONFIG_FILE = M.config_dir .. "/config.yml" .. "," .. M.theme_path
      else
        require("utils").error("Failed to get **lazygit** config directory, will not apply **lazygit** config.", { titile = "lazygit" })
      end
    end
  end

  return require("utils").terminal(cmd, opts)
end

return M
