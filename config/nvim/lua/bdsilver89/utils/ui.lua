local M = {}

---@param group string
---@param name string
---@param no_fallback? boolean
---@return string
function M.get_icon(group, name, no_fallback)
  local icons_enabled = vim.g.icons_enabled ~= false
  if not icons_enabled and no_fallback then
    return ""
  end
  local icons = assert(require("bdsilver89.config.icons")[icons_enabled and "icons" or "text_icons"])

  local icon_group = icons[group] or {}
  local icon = icon_group[name] or ""
  return icon
end

---@oaram group string
---@oaram no_fallback? boolean
---@return table|nil
function M.get_icon_group(group, no_fallback)
  local icons_enabled = vim.g.icons_enabled ~= false
  if not icons_enabled and no_fallback then
    return {}
  end
  local icons = assert(require("bdsilver89.config.icons")[icons_enabled and "icons" or "text_icons"])
  return icons[group] or {}
end

return M
