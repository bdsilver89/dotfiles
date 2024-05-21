local M = {}

local git_ns = vim.api.nvim_create_namespace("gitsigns_extmark_signs_")

function M.fill()
  return {
    provider = "%=",
  }
end

function M.foldcolumn()
  return {
    init = function(self)
      self.fold_closed = vim.fn.foldclosed(vim.v.lnum) >= 0
      self.can_fold = vim.fn.foldlevel(vim.v.lnum) > vim.fn.foldlevel(vim.v.lnum - 1)
    end,
    {
      condition = function(self)
        return self.can_fold
      end,
      provider = "%C",
    },
    {
      condition = function(self)
        return not self.can_fold
      end,
      provider = " ",
    },
  }
end

function M.gitcolumn()
  return {
    {
      conditon = function()
        return require("heirline.conditions").is_git_repo()
      end,
      init = function(self)
        local extmark = vim.api.nvim_buf_get_extmarks(
          0,
          git_ns,
          { vim.v.lnum - 1, 0 },
          { vim.v.lnum - 1, -1 },
          { limit = 1, details = true }
        )[1]

        self.sign = extmark and extmark[4]["sign_hl_group"]
        self.text = extmark and extmark[4]["sign_text"]
      end,
      {
        provider = function(self)
          local text = vim.fn.strcharpart(self.text or "", 0, 1)
          text = text .. string.rep(" ", 1 - vim.fn.strchars(text))
          return text .. "%*"
        end,
        hl = function(self)
          return self.sign or { fg = "bg" }
        end,
        -- on_click = {
        --   name = "sc_gitsigns_click",
        --   callback = function(self, ...)
        --     self.handlers.GitSigns(self.click_args(self, ...))
        --   end,
        -- },
      },
    },
    {
      conditon = function()
        return require("heirline.conditions").is_git_repo()
      end,
      provider = " ",
    },
  }
end

function M.numbercolumn()
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
      end
      if vim.v.virtnum ~= 0 then
        result = ""
      end
      return result .. " "
    end,
  }
end

function M.signcolumn()
  return {
    init = function(self)
      local extmark = vim.api.nvim_buf_get_extmarks(
        0,
        -1,
        { vim.v.lnum - 1, 0 },
        { vim.v.lnum - 1, -1 },
        { limit = 1, details = true }
      )[1]

      if extmark and extmark[4].ns_id ~= git_ns then
        self.sign = extmark[4]["sign_hl_group"]
        self.text = extmark[4]["sign_text"]
      end
    end,
    provider = function(self)
      local text = vim.fn.strcharpart(self.text or "", 0, 2)
      text = text .. string.rep(" ", 2 - vim.fn.strchars(text))
      return text .. "%*"
    end,
    hl = function(self)
      return self.sign or { fg = "bg" }
    end,
    -- on_click = {
    --   name = "sc_signcolumn_click",
    --   callback = function(self, ...)
    --     self.handlers.GitSigns(self.click_args(self, ...))
    --   end,
    -- },
  }
end

function M.space()
  return {
    provider = " ",
  }
end

return M
