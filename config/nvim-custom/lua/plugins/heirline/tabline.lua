local Utils = require("heirline.utils")
local Common = require("plugins.heirline.common")

local M = {}

local buflist_cache = {}

local function get_bufs()
  return vim.tbl_filter(function(bufnr)
    return vim.bo[bufnr].buflisted
  end, vim.api.nvim_list_bufs())
end

-- local function tabline_offset()
--   return {
--     conition = function(self)
--       local win = vim.api.nvim_tabpage_list_wins(0)[1]
--       local bufnr = vim.api.nvim_win_get_buf(win)
--       self.winid = win
--
--       if vim.bo[bufnr].filetype == "neo-tree" then
--         self.title = "NeoTree"
--         return true
--       end
--       return false
--     end,
--     provider = function(self)
--       local title = self.title
--       local width = vim.api.nvim_win_get_width(self.winid)
--       local pad = math.ceil((width - #title) / 2)
--       return string.rep(" ", pad) .. title .. string.rep(" ", pad)
--     end,
--     hl = function(self)
--       if vim.api.nvim_get_current_win() == self.winid then
--         return "TabLineSel"
--       else
--         return "TabLine"
--       end
--     end,
--   }
-- end

local function bufferblock()
  return Utils.surround({}, function(self)
    if self.is_active then
      return Utils.get_highlight("TabLineSel").bg
    else
      return Utils.get_highlight("TabLine").bg
    end
  end, {
    -- picker
    -- {
    --   condition = function(self)
    --     return self._show_picker
    --   end,
    --   init = function(self)
    --     local bufname = vim.api.nvim_buf_get_name(self.bufnr)
    --     bufname = vim.fn.fnamemodify(bufname, ":t")
    --     local label = bufname:sub(1, 1)
    --     local i = 2
    --     while self._picker_labels[label] do
    --       label = bufname:sub(i, i)
    --       if i > #bufname then
    --         break
    --       end
    --       i = i + 1
    --     end
    --     self._picker_labels[label] = self.bufnr
    --     self.label = label
    --   end,
    --   provider = function(self)
    --     return self.label
    --   end,
    --   hl = { fg = "red", bold = true },
    -- },

    -- filename block
    {
      init = function(self)
        self.filename = vim.api.nvim_buf_get_name(self.bufnr)
      end,
      hl = function(self)
        if self.is_active then
          return "TabLineSel"
        elseif not vim.api.nvim_buf_is_loaded(self.bufnr) then
          return { fg = "gray" }
        else
          return "TabLine"
        end
      end,
      on_click = {
        callback = function(_, minwid, nclicks)
          if nclicks == 1 then
            vim.api.nvim_win_set_buf(0, minwid)
          elseif nclicks == 2 then
            if vim.t.winrestcmd then
              vim.cmd(vim.t.winrestcmd)
              vim.t.winrestcmd = nil
            else
              vim.t.winrestcmd = vim.fn.winrestcmd()
              vim.cmd.wincmd("|")
              vim.cmd.wincmd("_")
            end
          end
        end,
        minwid = function(self)
          return self.bufnr
        end,
        name = "heirline_tabline_buffer_callback",
      },

      -- tabline buffer
      {},
      -- file icon
      {},
      -- filename
      {
        provider = function(self)
          local filename = vim.fn.fnamemodify(self.filename, ":t")
          if self.dupes and self.dupes[filename] then
            filename = vim.fn.fnamemodify(self.filename, ":h:t") .. "/" .. filename
          end
          filename = filename == "" and "[No Name]" or filename
          return filename
        end,
        hl = function(self)
          return { bold = self.is_active or self.is_visible, italic = true }
        end,
      },
      -- fileflags
      {},
    },

    -- close button
    {
      condition = function(self)
        return not vim.bo[self.bufnr].modified
      end,
      Common.space(),
      {
        provider = Common.icons.close,
        hl = { fg = "gray" },
        on_click = {
          callback = function(_, minwid)
            vim.schedule(function()
              vim.api.nvim_buf_delete(minwid, { force = false })
              vim.cmd.redrawtabline()
            end)
          end,
          minwid = function(self)
            return self.bufnr
          end,
          name = "heirline_tabline_close_buffer_callback",
        },
      },
    },
  })
end

local function bufferline()
  return Utils.make_buflist(
    bufferblock(),
    { provider = Common.icons.left_arrow, hl = { fg = "gray" } },
    { provider = Common.icons.right_arrow, hl = { fg = "gray" } },
    function()
      return buflist_cache
    end,
    false
  )
end

local function tabpage()
  return {
    {
      provider = function(self)
        return " %" .. self.tabnr .. "T" .. self.tabnr .. " "
      end,
      hl = { bold = true },
    },
    -- {
    --   provider = function(self)
    --     local n = #vim.api.nvim_tabpage_list_wins(self.tabpage)
    --     return n .. "%T "
    --   end,
    --   hl = { fg = "gray" },
    -- },
    hl = function(self)
      if not self.is_active then
        return "TabLine"
      else
        return "TabLineSel"
      end
    end,
    update = { "TabNew", "TabClosed", "TabEnter", "TabLeave", "WinNew", "WinClosed" },
  }
end

local function tabpages()
  return {
    condition = function()
      return #vim.api.nvim_list_tabpages() >= 2
    end,
    Common.align(),
    Utils.make_tablist(tabpage()),
    {
      provider = " %999X" .. Common.icons.close .. "%X",
      hl = { fg = "red" },
    },
  }
end

function M.setup()
  vim.api.nvim_create_autocmd({ "VimEnter", "UIEnter", "BufAdd", "BufDelete" }, {
    callback = function()
      vim.schedule(function()
        local buffers = get_bufs()
        for i, v in ipairs(buffers) do
          buflist_cache[i] = v
        end
        for i = #buffers + 1, #buflist_cache do
          buflist_cache[i] = nil
        end

        if #buflist_cache > 1 then
          vim.o.showtabline = 2
        elseif vim.o.showtabline ~= 1 then --otheriwise it breaks startup screen
          vim.o.showtabline = 1
        end
      end)
    end,
  })

  vim.api.nvim_create_autocmd({ "VimEnter", "UIEnter", "BufAdd", "BufDelete" }, {
    callback = function()
      local counts = {}
      local dupes = {}
      local names = vim.tbl_map(function(bufnr)
        return vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":t")
      end, get_bufs())
      for _, name in ipairs(names) do
        counts[name] = (counts[name] or 0) + 1
      end
      for name, count in pairs(counts) do
        if count > 1 then
          dupes[name] = true
        end
      end
      require("heirline").tabline.dupes = dupes
    end,
  })

  return {
    -- tabline_offset(),
    bufferline(),
    tabpages(),
  }
end

return M
