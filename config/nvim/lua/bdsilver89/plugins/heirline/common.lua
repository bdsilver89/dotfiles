local Conditions = require("heirline.conditions")
local HUtils = require("heirline.utils")
local Utils = require("bdsilver89.utils")

local M = {}

function M.space()
  return {
    provider = " ",
  }
end

function M.align()
  return {
    provider = "%=",
  }
end

function M.fileicon()
  return {
    init = function(self)
      local has_devicons, devicons = pcall(require, "nvim-web-devicons")
      self.has_devicons = has_devicons
      local filename = self.filename
      local extension = vim.fn.fnamemodify(filename, ":e")
      if has_devicons then
        self.icon, self.icon_color = devicons.get_icon_color(filename, extension, { default = true })
      end
    end,
    condition = function()
      local has_devicons, devicons = pcall(require, "nvim-web-devicons")
      return has_devicons
    end,
    provider = function(self)
      return self.icon and (self.icon .. " ")
    end,
    hl = function(self)
      if self.icon_color then
        return { fg = self.icon_color }
      end
      return ""
    end,
  }
end

function M.filename()
  return {
    provider = function(self)
      local filename = vim.fn.fnamemodify(self.filename, ":.")
      if filename == "" then
        return "[No Name]"
      end
      if not Conditions.width_percent_below(#filename, 0.25) then
        filename = vim.fn.pathshorten(filename)
      end
      return filename
    end,
    hl = function()
      if vim.bo.modified then
        return { fg = HUtils.get_highlight("Directory").fg }
      else
        return { fg = HUtils.get_highlight("Directory").fg }
      end
    end,
  }
end

function M.fileflags()
  return {
    {
      condition = function()
        return vim.bo.modified
      end,
      provider = Utils.ui.get_icon("misc", "Modified"),
      hl = { fg = "green" }
    },
    {
      condition = function()
        return not vim.bo.modifiable or vim.bo.readonly
      end,
      provider = Utils.ui.get_icon("misc", "Readonly"),
      hl = { fg = "orange" },
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
    { provider = "%<" },
  }
end

function M.filetype()
  return {
    provider = function()
      return string.upper(vim.bo.filetype)
    end,
    hl = { fg = HUtils.get_highlight("Type").fg, bold = true },
  }
end

function M.terminal_name()
  return {
    provider = function()
      local tname, _ = vim.api.nvim_buf_get_name(0):gsub(".*:", "")
      return Utils.ui.get_icon("misc", "Terminal") .. tname
    end,
    hl = { fg = "blue", bold = true },
  }
end

return M
