local M = {}

local function space()
  return {
    provider = " "
  }
end

local function align()
  return {
    provider = "%="
  }
end

local function tabline_bufnr()
  return {
    provider = function(self)
      return tostring(self.bufnr) .. ". "
    end,
    hl = "Comment"
  }
end

local function tabline_filename()
  return {
    provider = function(self)
      local filename = self.filename
      return filename == "" and "[No Name]" or vim.fn.fnamemodify(filename, ":t")
    end,
    hl = function(self)
      return { bold = self.is_active or self.is_visible, italic = true }
    end,
  }
end

local function tabline_fileflags()
  return {}
end

local function tabline_filenameblock()
  return {
    init = function(self)
      self.filename = vim.api.nvim_buf_get_name(self.bufnr)
    end,
    hl = function(self)
      if self.is_active then
        return "TabLineSel"
      else
        return "TabLine"
      end
    end,
    on_click = {
      callback = function(_, minwid, _, button)
        if button == "m" then
          vim.schedule(function() vim.api.nvim_buf_delete(minwid, { force = false }) end)
        else
          vim.api.nvim_win_set_buf(0, minwid)
        end
      end,
      minwid = function(self)
        return self.bufnr
      end,
      name = "heirline_tabline_buffer_callback",
    },
    tabline_bufnr(),
    -- file icon,
    tabline_filename(),
    -- fileflags
  }
end

local function tabline_closebutton()
  return {
    condition = function(self)
      return not vim.api.nvim_get_option_value("modified", { buf = self.bufnr })
    end,
    space(),
    {
      provider = "X",
      hl = { fg = "gray" },
      on_click = {
        callback = function(_, minwid)
          vim.schedule(function()
            vim.api.nvim_buf_Delete(minwid, { force = false })
            vim.cmd.redrawtabline()
          end)
        end,
        minwid = function(self)
          return self.bufnr
        end,
        name = "heirline_tabline_close_buffer_callback",
      },
    },
  }
end

local function tabline_bufferblock()
  return require("heirline.utils").surround({ "/", "\\" }, function(self)
    if self.is_active then
      return require("heirline.utils").get_highlight("TabLineSel").bg
    else
      return require("heirline.utils").get_highlight("TabLine").bg
    end
  end, { tabline_filenameblock(), tabline_closebutton() })
end

local function get_bufs()
  return vim.tbl_filter(function(bufnr)
    return vim.api.nvim_get_option_value("buflisted", { buf = bufnr })
  end, vim.api.nvim_list_bufs())
end

local buflist_cache = {}

local function bufferline()
  return require("heirline.utils").make_buflist({
    tabline_bufferblock(),
    {},
    {},
    function()
      return buflist_cache
    end,
  })
end


local function tabline()
  return {
    condition = function()
      return #vim.api.nvim_list_tabpages() >= 2
    end,
    align(),
    require("heirline.utils").make_tablist({
      provider = function(self)
        return "%" .. self.tabnr .. "T " .. self.tabpage .. " %T"
      end,
      hl = function(self)
        return self.is_active and "TabLineSel" or "TabLine"
      end,
    }),
    {
      provider = "%999X X %X",
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
        else
          vim.o.showtabline = 1
        end
      end)
    end,
  })

  return {
    -- bufferline(),
    align(),
    tabline(),
  }
end

return M
