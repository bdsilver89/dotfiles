local M = {}

function M.eval()
  local win = vim.g.statusline_winid
  local buf = vim.api.nvim_win_get_buf(win)
  local is_file = vim.bo[buf].buftype == ""
  local show_signs = vim.wo[win].signcolumn ~= "no"

  local components = { "", "", "" }

  local is_num = vim.wo[win].number
  local is_relnum = vim.wo[win].relativenumber
  if (is_num or is_relnum) and vim.v.virtnum == 0 then
    if vim.fn.has("nvim-0.11") == 1 then
      components[2] = "%l" -- 0.11 handles both the current and other lines with %l
    else
      if vim.v.relnum == 0 then
        components[2] = is_num and "%l" or "%r" -- the current line
      else
        components[2] = is_relnum and "%r" or "%l" -- other lines
      end
    end
    components[2] = "%=" .. components[2] .. " " -- right align
  end

  if vim.v.virtnum ~= 0 then
    components[2] = "%= "
  end

  return table.concat(components, "")
end

return M
