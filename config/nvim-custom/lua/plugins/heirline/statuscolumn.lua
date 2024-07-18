local Common = require("plugins.heirline.common")

local M = {}

local function spacer()
  return { provider = " ", hl = "HeirlineStatusColumn" }
end

---@alias Sign {name:string, text:string, texthl:string, priority:number}

---@param buf number
---@param lnum number
---@return Sign[]
local function get_signs(buf, lnum)
  local signs = {}
  local extmarks = vim.api.nvim_buf_get_extmarks(
    buf,
    -1,
    { lnum - 1, 0 },
    { lnum - 1, -1 },
    { details = true, type = "sign" }
  )
  for _, extmark in pairs(extmarks) do
    signs[#signs + 1] = {
      name = extmark[4].sign_hl_group or "",
      text = extmark[4].sign_text,
      texthl = extmark[4].sign_hl_group,
      priority = extmark[4].priority,
    }
  end

  -- Sort by priority
  table.sort(signs, function(a, b)
    return (a.priority or 0) < (b.priority or 0)
  end)

  return signs
end

---@param sign? Sign
---@param len? number
local function icon(sign, len)
  sign = sign or {}
  len = len or 2
  local text = vim.fn.strcharpart(sign.text or "", 0, len)
  text = text .. string.rep(" ", len - vim.fn.strchars(text))
  return text
end

local function signcolumn()
  return {
    condition = function()
      return vim.opt.signcolumn:get() ~= "no"
    end,
    init = function(self)
      self.sign = nil
      for _, s in ipairs(get_signs(0, vim.v.lnum)) do
        if s.name and not s.name:find("GitSign") then
          self.sign = s
        end
      end
      if vim.v.virtnum ~= 0 then
        self.sign = nil
      end
    end,
    provider = function(self)
      return icon(self.sign)
    end,
    hl = function(self)
      return self.sign and self.sign.texthl
    end,
  }
end

local function numbercolumn()
  return {
    provider = function()
      local is_num = vim.wo.number
      local is_relnum = vim.wo.relativenumber
      local result = ""
      if (is_num or is_relnum) and vim.v.virtnum == 0 then
        if vim.v.relnum == 0 then
          result = is_num and "%l" or "%r"
        else
          result = is_relnum and "%r" or "%l"
        end
        result = "%=" .. result .. " "
      end
      if vim.v.virtnum ~= 0 then
        result = "%= "
      end
      return result
    end,
  }
end

local function foldcolumn()
  return {
    init = function(self)
      self.fold_closed = vim.fn.foldclosed(vim.v.lnum) >= 0
      self.can_fold = vim.fn.foldlevel(vim.v.lnum) > vim.fn.foldlevel(vim.v.lnum - 1)
    end,
    {
      condition = function(self)
        return self.can_fold
      end,
      provider = function(self)
        local sign = {
          text = self.fold_closed and vim.opt.fillchars:get().foldclose or vim.opt.fillchars:get().foldopen,
        }
        return icon(sign)
      end,
    },
    {
      condition = function(self)
        return not self.can_fold
      end,
      spacer(),
      spacer(),
    },
  }
end

local function gitsigncolumn()
  return {
    {
      condition = function()
        return vim.opt.signcolumn:get() ~= "no" and require("heirline.conditions").is_git_repo()
      end,
      init = function(self)
        self.sign = nil
        for _, s in ipairs(get_signs(0, vim.v.lnum)) do
          if s.name and s.name:find("GitSign") then
            self.sign = s
          end
        end
      end,
      provider = function(self)
        return icon(self.sign, 1)
      end,
      hl = function(self)
        return self.sign and self.sign.texthl
      end,
    },
    {
      condition = function()
        return not require("heirline.conditions").is_git_repo()
      end,
      spacer(),
    },
  }
end

function M.setup()
  return {
    condition = function()
      return not require("heirline.conditions").buffer_matches({
        buftype = { "nofile", "prompt", "help", "quickfix", "terminal" },
        filetype = { "alpha", "dashboard", "harpoon", "oil", "lspinfo", "toggleterm" },
      })
    end,
    signcolumn(),
    Common.align(),
    numbercolumn(),
    foldcolumn(),
    gitsigncolumn(),
  }
end

return M
