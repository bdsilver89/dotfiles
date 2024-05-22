local Utils = require("plugins.heirline.utils")

local M = {}

local function resolve_sign(bufnr, lnum)
  --- TODO: remove when dropping support for Neovim v0.9
  -- if vim.fn.has "nvim-0.10" == 0 then
  --   for _, sign in ipairs(vim.fn.sign_getplaced(bufnr, { group = "*", lnum = lnum })[1].signs) do
  --     local defined = vim.fn.sign_getdefined(sign.name)[1]
  --     if defined then return defined end
  --   end
  -- end

  local row = lnum - 1
  local extmarks = vim.api.nvim_buf_get_extmarks(bufnr, -1, { row, 0 }, { row, -1 }, { details = true, type = "sign" })
  local ret
  for _, extmark in pairs(extmarks) do
    local sign_def = extmark[4]
    if sign_def.sign_text and (not ret or (ret.priority < sign_def.priority)) then
      ret = sign_def
    end
  end
  if ret then
    return { text = ret.sign_text, texthl = ret.sign_hl_group }
  end
end

---@return string
function M.fill()
  return "%="
end

---@param opts? table
---@return function
function M.foldcolumn(opts)
  opts = vim.tbl_deep_extend("force", {
    escape = false,
  }, opts or {})
  return function(self)
    local lnum = vim.v.lnum
    -- local fold_closed = vim.fn.foldclosed(lnum) >= 0
    local can_fold = vim.fn.foldlevel(lnum) > vim.fn.foldlevel(lnum - 1)

    local str
    if can_fold then
      str = "%C"
    else
      str = " "
    end
    return Utils.stylize(str, opts)
  end
end

---@param opts? table
---@return function
function M.gitsigncolumn(opts)
  opts = vim.tbl_deep_extend("force", {
    escape = false,
  }, opts or {})
  return function(self)
    local text = vim.fn.strcharpart(self.text or "", 0, 1)
    text = text .. string.rep(" ", 1 - vim.fn.strchars(text))
    return text .. "%*"
  end
end

---@param opts? table
---@return function
function M.macro_recording(opts)
  opts = vim.tbl_deep_extend("force", {
    prefix = "@",
  }, opts or {})
  return function()
    local register = vim.fn.reg_recording()
    if register ~= "" then
      register = opts.prefix .. register
    end
    return Utils.setup_providers(register, opts)
  end
end

---@param opts? table
---@return function
function M.numbercolumn(opts)
  opts = vim.tbl_deep_extend("force", {
    thousands = false,
    culright = true,
    escape = false,
  }, opts or {})
  return function(self)
    local lnum, rnum, virtnum = vim.v.lnum, vim.v.relnum, vim.v.virtnum
    local num, relnum = vim.opt.number:get(), vim.opt.relativenumber:get()
    local bufnr = self and self.bufnr or 0
    local sign = vim.opt.signcolumn:get():find("nu") and resolve_sign(bufnr, lnum)
    local str
    if virtnum ~= 0 then
      str = "%="
    elseif sign then
      str = sign.text
      if sign.texthl then
        str = "%#" .. sign.texthl .. "#" .. str .. "%*"
      end
      str = "%=" .. str
    elseif not num and not relnum then
      str = "%="
    else
      local cur = relnum and (rnum > 0 and rnum or (num and lnum or 0)) or lnum
      if opts.thousands and cur > 999 then
        cur = cur:reverse():gsub("%d%d%d", "%1" .. opts.thousands):reverse():gsub("^%" .. opts.thousands, "")
      end
      str = (rnum == 0 and not opts.culright and relnum) and cur .. "%=" or "%=" .. cur
    end
    return Utils.stylize(str, opts)
  end
end

---@param opts? table
---@return function
function M.percentage(opts)
  opts = vim.tbl_deep_extend("force", { escape = false, fixed_width = true, edge_text = true }, opts or {})
  return function()
    local text = "%" .. (opts.fixed_width and (opts.edge_text and "2" or "3") or "") .. "p%%"
    if opts.edge_text then
      local current_line = vim.fn.line(".")
      if current_line == 1 then
        text = "Top"
      elseif current_line == vim.fn.line("$") then
        text = "Bot"
      end
    end
    return Utils.stylize(text, opts)
  end
end

---@param opts? table
---@return function
function M.ruler(opts)
  opts = vim.tbl_deep_extend("force", { pad_ruler = { line = 3, char = 2 } }, opts or {})
  local padding_str = ("%%%dd:%%-%dd"):format(opts.pad_ruler.line, opts.pad_ruler.char)
  return function()
    local line = vim.fn.line(".")
    local char = vim.fn.virtcol(".")
    return Utils.stylize(padding_str:format(line, char), opts)
  end
end

---@param opts? table
---@return function
function M.scrollbar(opts)
  local sbar = { "▁", "▂", "▃", "▄", "▅", "▆", "▇", "█" }
  return function()
    local curr_line = vim.api.nvim_win_get_cursor(0)[1]
    local lines = vim.api.nvim_buf_line_count(0)
    local i = math.floor((curr_line - 1) / lines * #sbar) + 1
    if sbar[i] then
      return Utils.stylize(sbar[i]:rep(2), opts)
    end
  end
end

---@param opts? table
---@return string
function M.showcmd(opts)
  opts = vim.tbl_deep_extend("force", {
    minwid = 0,
    maxwid = 0,
    escape = false,
  }, opts or {})
  return Utils.stylize(("%%%d.%d(%%S%%)"):format(opts.minwid, opts.maxwid), opts)
end

---@param opts? table
---@return function
function M.search_count(opts)
  local search_func = vim.tbl_isempty(opts or {}) and function()
    return vim.fn.searchcount()
  end or function()
    return vim.fn.searchcount(opts)
  end
  return function()
    local search_ok, search = pcall(search_func)
    if search_ok and type(search) == "table" and search.total then
      return Utils.stylize(
        ("%s%d/%s%d"):format(
          search.current > search.maxcount and ">" or "",
          math.min(search.current, search.maxcount),
          search.incomplete == 2 and ">" or "",
          math.min(search.total, search.maxcount)
        ),
        opts
      )
    end
  end
end

---@param opts? table
---@return function
function M.signcolumn(opts)
  opts = vim.tbl_deep_extend("force", { escape = false }, opts or {})
  return function(self)
    local text = vim.fn.strcharpart(self.text or "", 0, 2)
    text = text .. string.rep(" ", 2 - vim.fn.strchars(text))
    return text .. "%*"
  end
end

return M
