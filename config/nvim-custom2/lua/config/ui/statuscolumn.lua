local function get_signs(buf, lnum)
  local signs = {}

  for _, sign in ipairs(vim.fn.sign_getplaced(buf, { group = "*", lnum = lnum })[1].signs) do
    local ret = vim.fn.sign_getdefined(sign.name)[1]
    if ret then
      ret.priority = sign.priority
      signs[#signs + 1] = ret
    end
  end

  local extmarks = vim.api.nvim_buf_get_extmarks(
    buf,
    -1,
    { lnum - 1, 0 },
    { lnum - 1, -1 },
    { details = true, type = "sign" }
  )
  for _, extmark in pairs(extmarks) do
    signs[#signs + 1] = {
      name = extmark[4].sign_hl_group or extmark[4].sign_name or "",
      text = extmark[4].sign_text,
      texthl = extmark[4].sign_hl_group,
      priority = extmark[4].priority,
    }
  end

  table.sort(signs, function(a, b)
    return (a.priority or 0) < (b.priority or 0)
  end)

  return signs
end

local function get_mark(buf, lnum)
  local marks = vim.fn.getmarklist(buf)
  vim.list_extend(marks, vim.fn.getmarklist())
  for _, mark in ipairs(marks) do
    if mark.pos[1] == buf and mark.pos[2] == lnum and mark.mark:match("[a-zA-Z]") then
      return { text = mark.mark:sub(2), texthl = "DiagnosticHint" }
    end
  end
end

local function icon(sign, len)
  sign = sign or {}
  len = len or 2

  local text = vim.fn.strcharpart(sign.text or "", 0, len) ---@type string
  text = text .. string.rep(" ", len - vim.fn.strchars(text))
  return sign.texthl and ("%#" .. sign.texthl .. "#" .. text .. "%*") or text
end

return function()
  local win = vim.g.statusline_winid
  local buf = vim.api.nvim_win_get_buf(win)
  local is_file = vim.bo[buf].buftype == ""
  local show_signs = vim.wo[win].signcolumn ~= "no"

  local result = { "", "", "", "" }

  if show_signs then
    local signs = get_signs(buf, vim.v.lnum)

    local left, right, fold
    for _, s in ipairs(signs) do
      if s.name and s.name:find("GitSign") then
        right = s
      else
        left = s
      end
    end

    vim.api.nvim_win_call(win, function()
      if vim.fn.foldclosed(vim.v.lnum) >= 0 then
        fold = { text = vim.opt.fillchars:get().foldclose or "", texthl = "Folded" }
      elseif tostring(vim.treesitter.foldexpr(vim.v.lnum)):sub(1, 1) == ">" then
        fold = { text = vim.opt.fillchars:get().foldopen or "" }
      end
    end)

    result[1] = icon(get_mark(buf, vim.v.lnum) or left)
    result[3] = is_file and icon(fold) or " "
    result[4] = is_file and icon(right, 1) or " "
  end

  local is_num = vim.wo[win].number
  local is_relnum = vim.wo[win].relativenumber
  if (is_num or is_relnum) and vim.v.virtnum == 0 then
    if vim.fn.has("nvim-0.11") == 1 then
      result[2] = "%l"
    else
      if vim.v.relnum == 0 then
        result[2] = is_num and "%l" or "%r"
      else
        result[2] = is_relnum and "%r" or "%l"
      end
    end
    result[2] = "%=" .. result[2] .. " "
  end

  if vim.v.virtnum ~= 0 then
    result[2] = "%= "
  end

  return table.concat(result)
end
