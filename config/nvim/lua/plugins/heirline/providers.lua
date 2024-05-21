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

return M
