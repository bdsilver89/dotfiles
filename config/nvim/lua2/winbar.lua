local icons = require("icons")

local M = {}

function M.render()
  if vim.api.nvim_win_get_config(0).relative ~= "" then
    return ""
  end
  if vim.bo.buftype ~= "" then
    return ""
  end

  local name = vim.fn.expand("%:.")
  if name == "" then
    return "%#WinBarNC#[No Name]%*"
  end

  local flags = ""
  if vim.bo.modified then
    flags = flags .. " " .. icons.misc.modified
  end
  if vim.bo.readonly then
    flags = flags .. " " .. icons.misc.readonly
  end

  return "%#WinBar#" .. name .. "%*" .. flags
end

vim.o.winbar = "%{%v:lua.require'winbar'.render()%}"

return M
