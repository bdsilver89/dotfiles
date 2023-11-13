local M = {}

function M.terminal()
  local components = { "TERMINAL" }

  return table.concat(components, " ")
end

---@param buf number
---@return string
function M.filetype(buf)
  local filepath = vim.api.nvim_buf_get_name(buf)
  local icon = ""
  local icon_hl = ""
  if vim.bo[buf].buftype ~= "" then
  else
    local extension = vim.fn.fnamemodify(filepath, ":e")
    local devicons_avail, devicons = pcall(require, "nvim-web-devicons")
    if devicons_avail then
      icon, icon_hl = devicons.get_icon(filepath, extension, { default = true })
    end
  end

  icon = icon ~= "" and icon or filepath

  return "%#" .. icon_hl .. "#" .. icon .. "%*"
end

---@param buf number
---@return string
function M.filename(buf)
  if vim.bo[buf].modified then
    return require("utils.icons").file.modified .. " "
  elseif not vim.bo[buf].modifiable or vim.bo[buf].readonly then
    return require("utils.icons").file.readonly .. " "
  elseif vim.bo[buf].buftype == "" or vim.bo.buftype == "help" then
    local filepath = vim.api.nvim_buf_get_name(buf)
    if filepath == "" then
      return "[No Name]"
    end

    local filename = vim.fn.fnamemodify(filepath, ":t")
    return filename
  else
    return ""
  end
end

---@param buf number
function M.path(buf)
  if vim.bo[buf].buftype == "" or vim.bo.buftype == "help" then
    local filepath = vim.api.nvim_buf_get_name(buf)
    local path = vim.fn.fnamemodify(filepath, ":~")

    local win_width = vim.api.nvim_win_get_width(0)
    local extrachars = 3 + 3 + vim.bo[buf].filetype:len()
    local remaining = win_width - extrachars

    local final
    local relative = vim.fn.fnamemodify(path, ":p:h:h:~") or ""
    if relative:len() < remaining then
      final = relative
    else
      local len = 0
      while len > 0 and type(final) ~= "string" do
        local attempt = vim.fn.pathshorten(path, len)
        final = attempt:len() < remaining and attempt
        len = len - 2
      end
      if not final then
        final = vim.fn.pathshorten(path, 1)
      end
    end

    return ("in %s%s "):format("%<", final)
  else
    return ""
  end
end

---@return string
function M.aerial()
  local aerial_avail, aerial = pcall(require, "aerial")
  if not aerial_avail then
    return ""
  end

  local data = aerial.get_location(true) or {}
  local children = {} ---@type string[]

  if #data > 0 then
    vim.list_extend(children, { " " })
  end

  local max_depth = 5
  local start_idx = #data - max_depth
  if start_idx > 0 then
    vim.list_extend(children, { require("utils.icons").misc.dots .. "  " })
  end

  for i, d in ipairs(data) do
    local text = string.gsub(d.name, "%%", "%%%%"):gsub("%s*->%s*", "")
    text = text .. " " .. d.icon

    local hlgroup = string.format("Aerial%sIcon", d.kind)
    hlgroup = vim.fn.exists(hlgroup) == 1 and hlgroup or ""

    local separator = ""
    if #data > 1 and i < #data then
      separator = "  "
    end
    text = text .. separator

    local line = "%#" .. hlgroup .. "#" .. text
    vim.list_extend(children, { line })
  end

  return table.concat(children, " ")
end

function M.setup()
  local winid = vim.g.actual_curwin or vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_win_get_buf(winid)

  local cfg = vim.api.nvim_win_get_config(winid)
  if cfg.relative > "" or cfg.external then
    return ""
  end

  if vim.bo[buf].filetype == "neo-tree" then
    local context = require("neo-tree.ui.selector").get_scrolled_off_node_text()
    if context == nil or context == "" then
      return "%*"
    else
      return context
    end
  end

  if vim.bo[buf].buftype == "terminal" then
    return M.terminal()
  end

  if vim.bo[buf].buftype == "help" then
    return "%*"
  end

  local components = {
    M.filetype(buf),
    M.filename(buf),
    -- M.path(buf),
    M.aerial(),
    "%=",
  }

  return table.concat(components, " ")
end

return M
