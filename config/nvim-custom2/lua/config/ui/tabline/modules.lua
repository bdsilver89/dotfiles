local order = { "offset", "buffers", "tabs", "buttons" }

vim.cmd("function! TbGoToBuf(bufnr,b,c,d) \n execute 'b'..a:bufnr \n endfunction")
vim.cmd([[
   function! TbKillBuf(bufnr,b,c,d) 
        call luaeval('require("config.ui.tabline").close_buffer(_A)', a:bufnr)
  endfunction]])

vim.cmd("function! TbNewTab(a,b,c,d) \n tabnew \n endfunction")
vim.cmd("function! TbGotoTab(tabnr,b,c,d) \n execute a:tabnr ..'tabnext' \n endfunction")
vim.cmd("function! TbCloseAllBufs(a,b,c,d) \n lua require('config.ui.tabline').close_all_bufs() \n endfunction")
-- vim.cmd("function! TbToggle_theme(a,b,c,d) \n lua require('base46').toggle_theme() \n endfunction")
vim.cmd("function! TbToggleTabs(a,b,c,d) \n let g:TbTabsToggled = !g:TbTabsToggled | redrawtabline \n endfunction")

local M = {}

local function txt(str, hl)
  str = str or ""
  return "%#Tb" .. hl .. "#" .. str
end

local function filename(str)
  return str:match("([^/\\]+)[/\\]*$")
end

local function gen_unique_name(oldname, index)
  for i2, nr2 in ipairs(vim.t.bufs) do
    if index ~= i2 and filename(vim.api.nvim_buf_get_name(nr2)) == oldname then
      return vim.fn.fnamemodify(vim.api.nvim_buf_get_name(vim.t.bufs[index]), ":p:.")
    end
  end
end

local function new_hl(group1, group2)
  local fg = vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID(group1)), "fg#")
  local bg = vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID("Tb" .. group2)), "bg#")
  vim.api.nvim_set_hl(0, group1 .. group2, { fg = fg, bg = bg })
  return "%#" .. group1 .. group2 .. "#"
end

local function button(str, hl, func, arg)
  str = hl and txt(str, hl) or str
  arg = arg or ""
  return "%" .. arg .. "@Tb" .. func .. "@" .. str .. "%X"
end

local function style_buf(nr, i)
  local icon = "󰈚"
  local is_curbuf = vim.api.nvim_get_current_buf() == nr
  -- TODO: highlights
  local tbHlName = "BufO" .. (is_curbuf and "n" or "ff")
  local icon_hl = new_hl("DevIconDefault", tbHlName)

  local name = filename(vim.api.nvim_buf_get_name(nr))
  name = gen_unique_name(name, i) or name
  name = (name == "" or not name) and " No Name " or name

  if name ~= " No Name " then
    local devicon, devicon_hl = require("nvim-web-devicons").get_icon(name)

    if devicon then
      icon = devicon
      icon_hl = new_hl(devicon_hl, tbHlName)
    end
  end

  local pad = math.floor((23 - #name - 5) / 2)
  pad = pad <= 0 and 1 or pad

  local maxname_len = 15

  name = string.sub(name, 1, 13) .. (#name > maxname_len and ".." or "")
  name = txt(" " .. name, tbHlName) -- TODO: highlights

  name = string.rep(" ", pad) .. (icon_hl .. icon .. name) .. string.rep(" ", pad - 1)

  local close_btn = button(" 󰅖 ", nil, "KillBuf", nr)
  name = button(name, nil, "GoToBuf", nr)

  local mod = vim.api.nvim_get_option_value("mod", { buf = nr })
  local cur_mod = vim.api.nvim_get_option_value("mod", { buf = 0 })

  if is_curbuf then
    close_btn = cur_mod and txt("  ", "BufOnModified") or txt(close_btn, "BufOnClose")
  else
    close_btn = mod and txt("  ", "BufOffModified") or txt(close_btn, "BufOffClose")
  end

  name = txt(name .. close_btn, "Buf0" .. (is_curbuf and "n" or "ff"))

  return name
end

local function available_space()
  local str = ""

  for _, key in ipairs(order) do
    if key ~= "buffers" then
      str = str .. M[key]()
    end
  end

  local modules = vim.api.nvim_eval_statusline(str, { use_tabline = true })
  return vim.o.columns - modules.width
end

function M.offset()
  local nvimtree_width = 0
  for _, win in pairs(vim.api.nvim_tabpage_list_wins(0)) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[vim.api.nvim_win_get_buf(win)].ft == "NvimTree" then
      nvimtree_width = vim.api.nvim_win_get_width(win) + 1
    end
  end

  return "%#NvimTreeNormal#" .. string.rep(" ", nvimtree_width)
end

function M.buffers()
  local buffers = {}
  local has_current = false

  for i, nr in ipairs(vim.t.bufs) do
    if ((#buffers + 1) * 23) > available_space() then
      if has_current then
        break
      end

      table.remove(buffers, 1)
    end

    has_current = vim.api.nvim_get_current_buf() == nr or has_current
    table.insert(buffers, style_buf(nr, i))
  end

  return table.concat(buffers) .. txt("%=", "Fill")
end

vim.g.TbTabsToggled = 0

function M.tabs()
  local result = ""
  local tabs = vim.fn.tabpagenr("$")

  if tabs > 1 then
    for nr = 1, tabs, 1 do
      -- TODO: highlights
      result = result .. button(" " .. nr .. " ", nil, "GotoTab", nr)
    end

    local new_tabtn = button("  ", "TabNewBtn", "NewTab")
    local tabstoggleBtn = button(" 󰅂 ", "TabTitle", "ToggleTabs")
    local small_btn = button(" 󰅁 ", "TabTitle", "ToggleTabs")

    return vim.g.TbTabsToggled == 1 and small_btn or new_tabtn .. tabstoggleBtn .. result
  end

  return ""
end

function M.buttons()
  local close_all_bufs = button(" 󰅖 ", "CloseAllBufsBtn", "CloseAllBufs")
  return close_all_bufs
end

return function()
  local result = {}

  for _, v in ipairs(order) do
    table.insert(result, M[v]())
  end

  return table.concat(result)
end
