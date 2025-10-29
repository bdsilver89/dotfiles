local M = {}

local function filename(str)
  return str:match("([^/\\]+)[/\\]*$")
end

local function new_hl(group1, group2)
  local fg = vim.api.nvim_get_hl(0, { name = group1 }).fg
  local bg = vim.api.nvim_get_hl(0, { name = "Tb" .. group2 }).bg
  vim.api.nvim_set_hl(0, group1 .. group2, { fg = fg, bg = bg })
  return "%#" .. group1 .. group2 .. "#"
end

local function gen_unique_name(name, index)
  for i, nr in ipairs(vim.t.bufs) do
    local filepath = filename(vim.api.nvim_buf_get_name(nr))
    if index ~= i and filepath == name then
      return vim.fn.fnamemodify(vim.api.nvim_buf_get_name(vim.t.bufs[index]), ":h:h") .. "/" .. name
    end
  end
end

function M.txt(str, hl)
  str = str or ""
  return "%#Tb" .. hl .. "#" .. str
end

function M.btn(str, hl, func, arg)
  str = hl and M.txt(str, hl) or str
  arg = arg or ""
  return "%" .. arg .. "@Tb" .. func .. "@" .. str .. "%X"
end

function M.style_buf(nr, i, w)
  local icon = "󰈚 "
  local is_curbuf = vim.api.nvim_get_current_buf() == nr
  local tbHlName = "Buf0" .. (is_curbuf and "n" or "ff")
  local icon_hl = new_hl("DevIconDefault", tbHlName)

  local name = filename(vim.api.nvim_buf_get_name(nr))
  name = name and (gen_unique_name(name, i) or name) or " No Name "

  if name ~= " No Name " then
    local ok, devicons = pcall(require, "nvim-web-devicons")
    if ok then
      local devicon, devicon_hl = devicons.get_icon(name)

      if devicon then
        icon = " " .. devicon .. " "
        icon_hl = new_hl(devicon_hl, tbHlName)
      end
    end
  end

  local pad = math.floor((w - #name - 5) / 2)
  pad = pad <= 0 and 1 or pad

  local maxname_len = w - 5
  name = string.sub(name, 1, maxname_len - 2) .. (#name > maxname_len and ".." or "")
  name = M.txt(name, tbHlName)

  name = string.rep(" ", pad - 1) .. (icon_hl .. icon .. name) .. string.rep(" ", pad - 1)

  local close_btn = M.btn(" 󰅖 ", nil, "KillBuf", nr)
  name = M.btn(name, nil, "GoToBuf", nr)

  local mod = vim.api.nvim_get_option_value("mod", { buf = nr })
  local cur_mod = vim.api.nvim_get_option_value("mod", { buf = 0 })

  if is_curbuf then
    close_btn = cur_mod and M.txt("  ", "BufOnModified") or M.txt(close_btn, "BufOnClose")
  else
    close_btn = mod and M.txt("  ", "BufOffModified") or M.txt(close_btn, "BufOffClose")
  end

  return M.txt(name .. close_btn, "Buf0" .. (is_curbuf and "n" or "ff"))
end

return M
