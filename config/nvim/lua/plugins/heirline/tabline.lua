local Utils = require("heirline.utils")

local M = {}

function M.bufferline_offset()
  return {
    condition = function(self)
      local win = vim.api.nvim_tabpage_list_wins(0)[1]
      local bufnr = vim.api.nvim_win_get_buf(win)
      self.winid = win

      if vim.bo[bufnr].filetype == "neo-tree" then
        self.title = "NeoTree"
        return true
      elseif vim.bo[bufnr].filetype == "undotree" then
        self.title = "UndoTree"
        return true
      end
    end,
    provider = function(self)
      local title = self.title
      local width = vim.api.nvim_win_get_width(self.winid)
      local pad = math.ceil((width - #title) / 2)
      return string.rep(" ", pad) .. title .. string.rep(" ", pad)
    end,
    hl = function(self)
      if vim.api.nvim_get_current_win() == self.winid then
        return "TablineSel"
      else
        return "Tabline"
      end
    end,
  }
end

function M.bufferline()
  return {}
end

function M.tabpages()
  return {
    condition = function()
      return #vim.api.nvim_list_tabpages() >= 2
    end,
    {
      provider = "%="
    },
    Utils.make_tablist({
      provider = function(self)
        return "%" .. self.tabnr .. "T " .. self.tabpage .. " %T"
      end,
      hl = function(self)
        if not self.is_active then
          return "TabLine"
        else
          return "TabLineSel"
        end
      end,
    }),
    {
      provider = "%999X X %X",
      hl = { fg = "red", bg = Utils.get_highlight("TabLine").bg },
    },
  }
end

function M.tabpages_offset()
  return {
    condition = function(self)
      local wins = vim.api.nvim_tabpage_list_wins(0)
      local win = wins[#wins]
      local bufnr = vim.api.nvim_win_get_buf(win)
      self.winid = win

      if vim.bo[bufnr].filetype == "trouble" then
        self.title = "Trouble"
        return true
      end
    end,
    provider = function(self)
      local title = self.title
      local width = vim.api.nvim_win_get_width(self.winid)
      local pad = math.ceil((width - #title) / 2)
      return string.rep(" ", pad) .. title .. string.rep(" ", pad)
    end,
    hl = function(self)
      if vim.api.nvim_get_current_win() == self.winid then
        return "TablineSel"
      else
        return "Tabline"
      end
    end,
  }
end

function M.setup()
  return {
    M.bufferline_offset(),
    M.bufferline(),
    M.tabpages(),
    -- FIX: there is a problem with this for right-hand panels (e.g trouble/aerial/etc)
    -- M.tabpages_offset(),
  }
end

return M
