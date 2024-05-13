local Conditions = require("heirline.conditions")
local Utils = require("heirline.utils")

local M = {}

function M.setup_colors()
  return {
    bright_bg = Utils.get_highlight("Folded").bg,
    bright_fg = Utils.get_highlight("Folded").fg,
    red = Utils.get_highlight("DiagnosticError").fg,
    dark_red = Utils.get_highlight("DiffDelete").bg,
    green = Utils.get_highlight("String").fg,
    blue = Utils.get_highlight("Function").fg,
    gray = Utils.get_highlight("NonText").fg,
    orange = Utils.get_highlight("Constant").fg,
    purple = Utils.get_highlight("Statement").fg,
    cyan = Utils.get_highlight("Special").fg,
    diag_warn = Utils.get_highlight("DiagnosticWarn").fg,
    diag_error = Utils.get_highlight("DiagnosticError").fg,
    diag_hint = Utils.get_highlight("DiagnosticHint").fg,
    diag_info = Utils.get_highlight("DiagnosticInfo").fg,
    git_del = Utils.get_highlight("GitSignsDelete").fg,
    git_add = Utils.get_highlight("GitSignsAdd").fg,
    git_change = Utils.get_highlight("GitSignsChange").fg,
  }
end

function M.align()
  return {
    provider = "%="
  }
end

function M.fileencoding()
  return {
    provider = function()
      local enc = (vim.bo.fenc ~= "" and vim.bo.fenc) or vim.o.enc
      return enc:upper() .. " "
    end,
  }
end

function M.fileflags()
  return {
    {
      condition = function()
        return vim.bo.modified
      end,
      provider = require("config.icons").get_icon("misc", "Modified"),
      hl = { fg = "green" }
    },
    {
      condition = function()
        return not vim.bo.modifiable or vim.bo.readonly
      end,
      provider = require("config.icons").get_icon("misc", "Readonly"),
      hl = { fg = "orange" },
    },
  }
end

function M.fileformat()
  return {
    provider = function()
      local fmt = vim.bo.fileformat
      return fmt:upper() .. " "
    end,
  }
end

function M.fileicon()
  return {
    init = function(self)
      local filename = self.filename
      local extension = vim.fn.fnamemodify(filename, ":e")
      local has_devicons, devicons = pcall(require, "nvim-web-devicons")
      if has_devicons then
        self.icon, self.icon_color = devicons.get_icon_color(filename, extension, { default = true })
      end
    end,
    provider = function(self)
      return self.icon and (self.icon .. " ")
    end,
    hl = function(self)
      return self.icon_color and { fg = self.icon_color }
    end,
  }
end

function M.filename()
  return {
    init = function(self)
      self.lfilename = vim.fn.fnamemodify(self.filename, ":.")
      if self.lfilename == "" then
        self.lfilename = "[No Name]"
      end
      if not Conditions.width_percent_below(#self.lfilename, 0.27) then
        self.lfilename = vim.fn.pathshorten(self.lfilename)
      end
    end,
    -- hl = function()
    --   if vim.bo.modified then
    --     return { fg = Utils.get_highlight("Directory").fg, bold = true, italic = true }
    --   end
    -- end,
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

function M.filenameblock()
  return {
    init = function(self)
      self.filename = vim.api.nvim_buf_get_name(0)
    end,
    M.fileicon(),
    M.filename(),
    M.space(),
    M.fileflags(),
  }
end

function M.filesize()
  return {
    provider = function()
      local suffix = { "b", "k", "M", "G", "T", "P", "E" }
      local fsize = vim.fn.getsize(vim.api.nvim_buf_get_name(0))
      fsize = (fsize < 0 and 0) or fsize
      if fsize <= 0 then
        return "0" .. suffix[1]
      end
      local i = math.floor((math.log(fsize) / math.log(1024)))
      return string.format("%.2g%s", fsize / math.pow(1024, i), suffix[i])
    end,
  }
end

function M.filetype()
  return {
    provider = function()
      return string.upper(vim.bo.filetype)
    end,
    hl = "Type",
  }
end

function M.space()
  return {
    provider = " "
  }
end

-- function M.terminalname()
--   return {
--     {
--       provider = function()
--         local icon = vim.g.enable_icons and " " or ""
--         local tname, _ = vim.api.nvim_buf_get_name(0):gsub(".*:", "")
--         return icon .. tname
--       end,
--     },
--     {
--       provider = " - ",
--     },
--     {
--       provider = function()
--           return vim.b.term_title
--       end,
--     },
--   }
-- end

return M
