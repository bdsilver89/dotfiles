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
  local has_lazy, lazy_config = pcall(require, "lazy.core.config")
  if not has_lazy then
    return nil
  end
  return lazy_config.spec.plugins[name]
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

---@param buf? number
function M.bufremove(buf)
  buf = buf or 0
  buf = buf == 0 and vim.api.nvim_get_current_buf() or buf

  if vim.bo.modified then
    local choice = vim.fn.confirm(("Save changes to %q?"):format(vim.fn.bufname()), "&Yes\n&No\n&Cancel")
    if choice == 0 or choice == 3 then
      return
    end
    if choice == 1 then
      vim.cmd.write()
    end
  end

  for _, win in ipairs(vim.fn.win_findbuf(buf)) do
    vim.api.nvim_win_call(win, function()
      if not vim.api.nvim_win_is_valid(win) or vim.api.nvim_win_get_buf(win) ~= buf then
        return
      end

      -- first try setting to alternate buffer if an appropriate one is found
      local alt = vim.fn.bufnr("#")
      if alt ~= buf and vim.fn.buflisted(alt) == 1 then
        vim.api.nvim_win_set_buf(win, alt)
        return
      end

      -- try previous buffer
      local has_previous = pcall(vim.cmd, "bprevious")
      if has_previous and buf ~= vim.api.nvim_win_get_buf(win) then
        return
      end

      -- create new listed buffer
      local new_buf = vim.api.nvim_create_buf(true, false)
      vim.api.nvim_win_set_buf(win, new_buf)
    end)
  end

  if vim.api.nvim_buf_is_valid(buf) then
    pcall(vim.cmd, "bdelete! " .. buf)
  end
end

return M
