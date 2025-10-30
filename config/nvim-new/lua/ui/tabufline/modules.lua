local M = {}

local utils = require("ui.tabufline.utils")

local bufwidth = 21

vim.cmd([[
  function! TbGoToBuf(bufnr,b,c,d)
    call luaeval('require("ui.tabufline").goto(_A)', a:bufnr)
  endfunction]])

vim.cmd([[
  function! TbKillBuf(bufnr,b,c,d)
    call luaeval('require("ui.tabufline").close(_A)', a:bufnr)
  endfunction]])

vim.cmd("function! TbNewTab(a,b,c,d) \n tabnew \n endfunction")
vim.cmd("function! TbGotoTab(tabnr,b,c,d) \n execute a:tabnr ..'tabnext' \n endfunction")
vim.cmd("function! TbCloseAllBufs(a,b,c,d) \n lua require('ui.tabufline').closeAllBufs() \n endfunction")
-- vim.cmd("function! TbToggle_theme(a,b,c,d) \n lua require('base46').toggle_theme() \n endfunction")
-- vim.cmd("function! TbToggleTabs(a,b,c,d) \n let g:TbTabsToggled = !g:TbTabsToggled | redrawtabline \n endfunction")

local function available_space()
  local str = ""

  for _, key in ipairs({ "tree_offset", "buffers", "tabs", "buttons" }) do
    if key ~= "buffers" then
      str = str .. M[key]()
    end
  end

  local modules = vim.api.nvim_eval_statusline(str, { use_tabline = true })
  return vim.o.columns - modules.width
end

function M.tree_offset()
  local w = 0
  for _, win in pairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.bo[vim.api.nvim_win_get_buf(win)].ft == "NvimTree" then
      w = vim.api.nvim_win_get_width(win)
      break
    end
  end

  return w == 0 and "" or "%#NvimTreeNormal#" .. string.rep(" ", w) .. "%#NvimTreeWinSeparator#" .. "│"
end

function M.buffers()
  local buffers = {}

  local has_current = false

  vim.t.bufs = vim.tbl_filter(vim.api.nvim_buf_is_valid, vim.t.bufs)

  for i, buf in ipairs(vim.t.bufs) do
    if ((#buffers + 1) * bufwidth) > available_space() then
      if has_current then
        break
      end

      table.remove(buffers, 1)
    end

    has_current = vim.api.nvim_get_current_buf() == buf or has_current
    table.insert(buffers, utils.style_buf(buf, i, bufwidth))
  end

  return table.concat(buffers) .. utils.txt("%=", "Fill")
end

function M.tabs()
  return ""
end

function M.buttons()
  return ""
end

return M
