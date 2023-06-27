local utils = require("heirline.utils")
local Utils = require("bdsilver89.utils")
local conditions = require("heirline.conditions")

local M = {}

function M.null()
  return { provider = "" }
end

function M.align()
  return { provider = "%=" }
end

function M.space()
  return { provider = " " }
end

function M.vimode()
  return utils.surround({ "", "" }, "bright_bg", {
    M.macro_rec(),
    {
      init = function(self)
        self.mode = vim.fn.mode(1)
      end,
      static = {
        mode_names = {
          n = "N",
          no = "N?",
          nov = "N?",
          noV = "N?",
          ["no\22"] = "N?",
          niI = "Ni",
          niR = "Nr",
          niV = "Nv",
          nt = "Nt",
          v = "V",
          vs = "Vs",
          V = "V_",
          Vs = "Vs",
          ["\22"] = "^V",
          ["\22s"] = "^V",
          s = "S",
          S = "S_",
          ["\19"] = "^S",
          i = "I",
          ic = "Ic",
          ix = "Ix",
          R = "R",
          Rc = "Rc",
          Rx = "Rx",
          Rv = "Rv",
          Rvc = "Rv",
          Rvx = "Rv",
          c = "C",
          cv = "Ex",
          r = "...",
          rm = "M",
          ["r?"] = "?",
          ["!"] = "!",
          t = "T",
        },
      },
      provider = function(self)
        return Utils.get_icon("Vim") .. "%2(" .. self.mode_names[self.mode] .. "%)"
      end,
      hl = function(self)
        local color = self:mode_color()
        return { fg = color, bold = true }
      end,
      update = {
        "ModeChanged",
        pattern = "*:*",
        callback = vim.schedule_wrap(function()
          vim.cmd("redrawstatus")
        end),
      },
    },
    M.snippets(),
    M.show_cmd(),
  })
end

function M.file_icon()
  return {
    init = function(self)
      local filename = self.filename
      local extension = vim.fn.fnamemodify(filename, ":e")
      self.icon, self.icon_color = require("nvim-web-devicons").get_icon_color(filename, extension, { default = true })
    end,
    provider = function(self)
      return self.icon and (self.icon .. " ")
    end,
    hl = function(self)
      return { fg = self.icon_color }
    end,
  }
end

function M.file_name()
  return {
    init = function(self)
      self.lfilename = vim.fn.fnamemodify(self.filename, ":.")
      if self.lfilename == "" then
        self.lfilename = "[No Name]"
      end
      if not conditions.width_percent_below(#self.lfilename, 0.27) then
        self.lfilename = vim.fn.pathshorten(self.lfilename)
      end
    end,
    hl = function()
      if vim.bo.modified then
        return { fg = utils.get_highlight("Directory").fg, bold = true, italic = true }
      end
      return "Directory"
    end,
    flexible = 2,
    {
      provider = function(self)
        return self.lfilename
      end,
    },
    {
      provider = function(self)
        return vim.fn.pathshorten(self.lfilename)
      end,
    },
  }
end

function M.file_flags()
  return {
    {
      condition = function()
        return vim.bo.modified
      end,
      provider = vim.g.icons_enabled and " ● " or "[+]",
      hl = { fg = "green" },
    },
    {
      condition = function()
        return not vim.bo.modifiable or vim.bo.readonly
      end,
      provider = "",
      hl = { fg = "orange" },
    },
  }
end

function M.file_name_block()
  return {
    init = function(self)
      self.filename = vim.api.nvim_buf_get_name(0)
    end,
    M.file_icon(),
    M.file_name(),
    unpack(M.file_flags()),
  }
end

function M.file_type()
  return {
    provider = function()
      return string.upper(vim.bo.filetype)
    end,
    hl = "Type",
  }
end

function M.file_encoding()
  return {
    provider = function()
      local enc = (vim.bo.fenc ~= "" and vim.bo.fenc) or vim.o.enc -- :h 'enc'
      return enc ~= "utf-8" and enc:upper()
    end,
  }
end

function M.file_format()
  return {
    provider = function()
      local fmt = vim.bo.fileformat
      return fmt ~= "unix" and fmt:upper()
    end,
  }
end

function M.file_size()
  return {
    provider = function()
      local suffix = { "b", "k", "M", "G", "T", "P", "E" }
      local fsize = vim.fn.getfsize(vim.api.nvim_buf_get_name(0))
      fsize = (fsize < 0 and 0) or fsize
      if fsize <= 0 then
        return "0" .. suffix[1]
      end
      local i = math.floor((math.log(fsize) / math.log(1024)))
      return string.format("%.2g%s", fsize / math.pow(1024, i), suffix[i])
    end,
  }
end

function M.file_last_modified()
  return {
    provider = function()
      local ftime = vim.fn.getftime(vim.api.nvim_buf_get_name(0))
      return (ftime > 0) and os.date("%c", ftime)
    end,
  }
end

function M.ruler()
  -- FIXME: the percentage section of this thing is not very accurate (doesn't update often/enough)!
  return {
    provider = "%7(%l/%3L%):%2c %P",
  }
end

function M.scrollbar()
  return {
    static = {
      sbar = { "▁", "▂", "▃", "▄", "▅", "▆", "▇", "█" },
    },
    provider = function(self)
      local curr_line = vim.api.nvim_win_get_cursor(0)[1]
      local lines = vim.api.nvim_buf_line_count(0)
      local i = math.floor(curr_line / lines * (#self.sbar - 1)) + 1
      return string.rep(self.sbar[i], 2)
    end,
    hl = { fg = "blue", bg = "bright_bg" },
  }
end

function M.lsp_active()
  return {
    condition = conditions.lsp_attached,
    update = { "LspAttach", "LspDetach", "WinEnter" },
    provider = function()
      return Utils.get_icon("ActiveLsp") .. " LSP"
    end,
    hl = { fg = "green", bold = true },
    on_click = {
      name = "heirline_lsp",
      callback = function()
        vim.schedule(function()
          vim.cmd("LspInfo")
        end)
      end,
    },
  }
end

-- TODO:
-- navic
-- diagnostics

function M.snippets()
  return {
    condition = function()
      return vim.tbl_contains({ "s", "i" }, vim.fn.mode())
    end,
    provider = function()
      local forward = require("luasnip").jumpable(1) and " " or ""
      local backward = require("luasnip").jumpable(-1) and " " or ""
      return backward .. forward
    end,
    hl = { fg = "red", bold = true },
  }
end

-- TODO:
-- dapmessages

-- TODO: lots

function M.macro_rec()
  return {
    condition = function()
      return vim.fn.reg_recording() ~= "" and vim.o.cmdheight == 0
    end,
    provider = " ",
    hl = { fg = "orange", bold = true },
    utils.surround({ "[", "]" }, nil, {
      provider = function()
        return vim.fn.reg_recording()
      end,
      hl = { fg = "green", bold = true },
    }),
    update = {
      "RecordingEnter",
      "RecordingLeave",
    },
    { provider = " " },
  }
end

function M.show_cmd()
  return {
    condition = function()
      return vim.o.cmdheight == 0
    end,
    provider = ":%3.5(%S%)",
    hl = function(self)
      return { bold = true, fg = self:mode_color() }
    end,
  }
end

function M.close_button()
  return {
    condition = function(self)
      return not vim.bo.modified
    end,
    update = { "WinNew", "WinClosed", "BufEnter" },
    { provider = " " },
    {
      provider = Utils.get_icon("TabClose"),
      hl = { fg = "gray" },
      on_click = {
        callback = function(_, minwid)
          vim.api.nvim_win_close(minwid, true)
        end,
        minwid = function()
          return vim.api.nvim_get_current_win()
        end,
        name = "heirline_winbar_close_button",
      },
    },
  }
end

function M.tabline_bufnr()
  return {
    provider = function(self)
      return tostring(self.bufnr) .. ". "
    end,
    hl = "Comment",
  }
end

function M.tabline_file_name()
  return {
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
  }
end

function M.tabline_file_flags()
  return {
    {
      condition = function(self)
        return vim.api.nvim_buf_get_option(self.bufnr, "modified")
      end,
      provider = " ● ", --"[+]",
      hl = { fg = "green" },
    },
    {
      condition = function(self)
        return not vim.api.nvim_buf_get_option(self.bufnr, "modifiable")
          or vim.api.nvim_buf_get_option(self.bufnr, "readonly")
      end,
      provider = function(self)
        if vim.api.nvim_buf_get_option(self.bufnr, "buftype") == "terminal" then
          return "  "
        else
          return ""
        end
      end,
      hl = { fg = "orange" },
    },
    {
      condition = function(self)
        return not vim.api.nvim_buf_is_loaded(self.bufnr)
      end,
      -- a downright arrow
      provider = " 󰘓 ", --󰕁 
      hl = { fg = "gray" },
    },
  }
end

function M.tabline_file_block()
  return {
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
      callback = function(self, minwid, nclicks)
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
    M.tabline_bufnr(),
    M.file_icon(),
    M.tabline_file_name(),
    M.tabline_file_flags(),
  }
end

function M.tabline_close_button()
  return {
    condition = function(self)
      -- return not vim.bo[self.bufnr].modified
      return not vim.api.nvim_buf_get_option(self.bufnr, "modified")
    end,
    { provider = " " },
    {
      provider = icons.close,
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
  }
end

function M.tabline_picker()
  return {
    condition = function(self)
      return self._show_picker
    end,
    init = function(self)
      local bufname = vim.api.nvim_buf_get_name(self.bufnr)
      bufname = vim.fn.fnamemodify(bufname, ":t")
      local label = bufname:sub(1, 1)
      local i = 2
      while self._picker_labels[label] do
        label = bufname:sub(i, i)
        if i > #bufname then
          break
        end
        i = i + 1
      end
      self._picker_labels[label] = self.bufnr
      self.label = label
    end,
    provider = function(self)
      return self.label
    end,
    hl = { fg = "red", bold = true },
  }
end

function M.tabline_buffer_block()
  return utils.surround({ "", "" }, function(self)
    if self.is_active then
      return utils.get_highlight("TabLineSel").bg
    else
      return utils.get_highlight("TabLine").bg
    end
  end, { M.tabline_picker(), M.tabline_file_block(), tabline_close_button() })
end

local get_bufs = function()
  return vim.tbl_filter(function(bufnr)
    return vim.api.nvim_buf_get_option(bufnr, "buflisted")
  end, vim.api.nvim_list_bufs())
end

local buflist_cache = {}

vim.api.nvim_create_autocmd({ "VimEnter", "UIEnter", "BufAdd", "BufDelete" }, {
  callback = function(args)
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

function M.bufferline()
  return utils.make_buflist(
    M.tabline_buffer_block(),
    { provider = " ", hl = { fg = "gray" } },
    { provider = " ", hl = { fg = "gray" } },
    function()
      return buflist_cache
    end,
    false
  )
end

return M
