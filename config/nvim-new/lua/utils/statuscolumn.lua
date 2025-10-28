local M = {}

local config = {
  left = { "mark", "sign" },
  right = { "fold", "git" },
  folds = {
    open = true,
    git_hl = false,
  },
  refresh = 50,
}

local sign_cache = {}
local cache = {}
local icon_cache = {}

local function _ffi()
  if not C then
    local ffi = require("ffi")
    ffi.cdef([[
      typedef struct {} Error;
      typedef struct {} win_T;
      typedef struct {
        int start;
        int level;
        int llevel;
        int lines;
      } foldinfo_T;
      foldinfo_T fold_info(win_T* wp, int lnum);
      win_T *find_window_by_handle(int Window, Error *err);
    ]])
    C = ffi.C
  end
  return C
end

local function fold_info(win, lnum)
  pcall(_ffi)
  if not C then
    return
  end
  local ffi = require("ffi")
  local err = ffi.new("Error")
  local wp = C.find_window_by_handle(win, err)
  if wp == nil then
    return
  end
  return C.fold_info(wp, lnum)
end

local function is_git_sign(name)
  for _, pattern in ipairs({ "GitSign", "MiniDiffSign" }) do
    if name:find(pattern) then
      return true
    end
  end
end

local function buf_signs(buf)
  local signs = {}

  local extmarks = vim.api.nvim_buf_get_extmarks(buf, -1, 0, -1, { details = true, type = "sign" })
  for _, extmark in pairs(extmarks) do
    local lnum = extmark[2] + 1
    signs[lnum] = signs[lnum] or {}
    local name = extmark[4].sign_hl_group or extmark[4].sign_name or ""
    table.insert(signs[lnum], {
      name = name,
      type = is_git_sign(name) and "git" or "sign",
      text = extmark[4].sign_text,
      texthl = extmark[4].sign_hl_group,
      priority = extmark[4].priority,
    })
  end

  local marks = vim.fn.getmarklist(buf)
  vim.list_extend(marks, vim.fn.getmarklist())
  for _, mark in ipairs(marks) do
    if mark.pos[1] == buf and mark.mark:match("[a-zA-Z]") then
      local lnum = mark.pos[2]
      signs[lnum] = signs[lnum] or {}
      table.insert(signs[lnum], {
        text = mark.mark:sub(2),
        texthl = "DiagnosticHint",
        type = "mark",
      })
    end
  end

  return signs
end

local function line_signs(win, buf, lnum)
  local bsigns = sign_cache[buf]
  if not bsigns then
    bsigns = buf_signs(buf)
    sign_cache[buf] = bsigns
  end
  local signs = bsigns[lnum] or {}

  vim.api.nvim_win_call(win, function()
    if vim.fn.foldclosed(lnum) >= 0 then
      signs[#signs + 1] = { text = vim.opt.fillchars:get().foldclose or "", texthl = "Folded", type = "fold" }
    elseif config.folds.open then
      local info = fold_info(win, lnum)
      if info and info.level > 0 and info.start == lnum then
        signs[#signs + 1] = { text = vim.opt.fillchars:get().foldopen or "", type = "fold" }
      end
    end
  end)

  table.sort(signs, function(a, b)
    return (a.priority or 0) > (b.priority or 0)
  end)
  return signs
end

local function icon(sign)
  if not sign then
    return "  "
  end
  local key = (sign.text or "") .. (sign.texthl or "")
  if icon_cache[key] then
    return icon_cache[key]
  end
  local text = vim.fn.strcharpart(sign.text or "", 0, 2) ---@type string
  text = text .. string.rep(" ", 2 - vim.fn.strchars(text))
  icon_cache[key] = sign.texthl and ("%#" .. sign.texthl .. "#" .. text .. "%*") or text
  return icon_cache[key]
end

function M.click_fold()
  local pos = vim.fn.getmousepos()
  vim.api.nvim_win_set_cursor(pos.winid, { pos.line, 1 })
  vim.api.nvim_win_call(pos.winid, function()
    if vim.fn.foldlevel(pos.line) > 0 then
      vim.cmd("normal! za")
    end
  end)
end

function M.render()
  local win = vim.g.statusline_winid
  local nu = vim.wo[win].number
  local rnu = vim.wo[win].relativenumber
  local show_signs = vim.v.virtnum == 0 and vim.wo[win].signcolumn ~= "no"
  local components = { "", "", "" }
  if not (show_signs or nu or rnu) then
    return ""
  end

  if (nu or rnu) and vim.v.virtnum == 0 then
    local num
    if rnu and nu and vim.v.relnum == 0 then
      num = vim.v.lnum
    elseif rnu then
      num = vim.v.relnum
    else
      num = vim.v.lnum
    end
    components[2] = "%=" .. num .. " "
  end

  if show_signs then
    local buf = vim.api.nvim_win_get_buf(win)
    local is_file = vim.bo[buf].buftype == ""
    local signs = line_signs(win, buf, vim.v.lnum)

    if #signs > 0 then
      local signs_by_type = {}
      for _, s in ipairs(signs) do
        signs_by_type[s.type] = signs_by_type[s.type] or s
      end

      local function find(types)
        for _, t in ipairs(types) do
          if signs_by_type[t] then
            return signs_by_type[t]
          end
        end
      end

      local left_c = type(config.left) == "function" and config.left(win, buf, vim.v.lnum) or config.left
      local right_c = type(config.right) == "function" and config.right(win, buf, vim.v.lnum) or config.right
      local left, right = find(left_c), find(right_c)

      if config.folds.git_hl then
        local git = signs_by_type.git
        if git and left and left.type == "fold" then
          left.texthl = git.texthl
        end
        if git and right and right.type == "fold" then
          right.texthl = git.texthl
        end
      end
      components[1] = left and icon(left) or "  "
      components[3] = is_file and (right and icon(right) or "  ") or ""
    else
      components[1] = "  "
      components[3] = is_file and "  " or ""
    end
  end

  local ret = table.concat(components, "")
  return "%@v:lua.require'utils.statuscolumn'.click_fold@" .. ret .. "%T"
end

function M.get()
  local win = vim.g.statusline_winid
  local buf = vim.api.nvim_win_get_buf(win)
  local key = ("%d:%d:%d:%d:%d"):format(win, buf, vim.v.lnum, vim.v.virtnum ~= 0 and 1 or 0, vim.v.relnum)
  if cache[key] then
    return cache[key]
  end
  local ok, ret = pcall(M.render)
  if ok then
    cache[key] = ret
    return ret
  end
  return ""
end

function M.setup()
  vim.o.statuscolumn = "%!v:lua.require('utils.statuscolumn').get()"

  local timer = vim.uv.new_timer()
  if timer then
    timer:start(config.refresh, config.refresh, function()
      sign_cache = {}
      cache = {}
    end)
  end
end

return M
