local Conditions = require("heirline.conditions")
local Common = require("plugins.base.heirline.common")

local M = {}

function M.filetype()
  return {
    init = function(self)
      if vim.bo.buftype ~= "" then
        self.icon = ""
        self.icon_color = ""
      else
        local extension = vim.fn.fnamemodify(self.filepath, ":e")
        local devicons_avail, devicons = pcall(require, "nvim-web-devicons")
        if devicons_avail then
          self.icon, self.icon_color = devicons.get_icon_color(self.filepath, extension, { default = true })
        end
      end
    end,
    provider = function(self)
      -- return self.icon ~= "" and (" %s %s "):format(self.icon, self.filetype_text) or self.filetype_text .. " "
      return (self.icon ~= "" and self.icon or self.filetype_text) .. " "
    end,
    hl = function(self)
      if self.icon_color then
        return { fg = self.icon_color }
      end
    end,
  }
end

-- function M.terminal()
--   return {
--     condition = function()
--       return vim.bo.buftype == "terminal"
--     end,
--     provider = function()
--       return " [<A-i> hide] [A-x mode] "
--     end,
--   }
-- end

function M.filename()
  return {
    {
      condition = function()
        return vim.bo.modified
      end,
      {
        provider = require("utils.icons").file.modified,
      },
      {
        provider = " ",
      },
    },
    {
      condition = function()
        return not vim.bo.modifiable or vim.bo.readonly
      end,
      {
        provider = require("utils.icons").file.readonly,
      },
      {
        provider = " ",
      },
    },
    {
      condition = function()
        return vim.bo.buftype == "" or vim.bo.buftype == "help"
      end,
      provider = function(self)
        if self.filepath == "" then
          return "[No Name]"
        end

        local filename = vim.fn.fnamemodify(self.filepath, ":t")
        return ("%s"):format(filename)
      end,
    },
  }
end

function M.path()
  return {
    condition = function()
      return vim.bo.buftype == "" or vim.bo.buftype == "help"
    end,
    {
      providers = function(self)
        if self.filepath == "" then
          return ""
        end

        local path = vim.fn.fnamemodify(self.filepath, ":~h")

        local win_width = vim.api.nvim_win_get_width(0)
        local extrachars = 3 + 3 + self.filetype_text:len()
        local remaining = win_width - extrachars

        local final
        local relative = vim.fn.fnamemodify(path, ":~:.") or ""
        if relative:len() < remaining then
          final = relative
        else
          local len = 0
          while len > 0 and type(final) ~= "string" do
            local attempt = vim.fn.pathshorten(path, len)
            final = attempt:len() < remaining and attempt
            len = len - 2
          end
          if not final then
            final = vim.fn.pathshorten(path, 1)
          end
        end
        return ("in %s%s/ "):format("%<", final)
      end,
    },
  }
end

function M.aerial()
  return {
    init = function(self)
      local data = require("aerial").get_location(true) or {}
      local children = {}

      if #data > 0 then
        table.insert(children, { provider = "  " })
      end

      local max_depth = 5
      local start_idx = #data - max_depth
      if start_idx > 0 then
        table.insert(children, { provider = require("utils.icons").misc.dots .. "  " })
      end

      for i, d in ipairs(data) do
        local child = {
          { provider = string.gsub(d.name, "%%", "%%%%"):gsub("%s*->%s*", "") },
          -- on_click = {
          --   name = "aerial_click",
          --   -- minwid =
          -- }
        }

        local hlgroup = string.format("Aerial%sIcon", d.kind)
        table.insert(child, 1, {
          provider = string.format("%s", d.icon),
          hl = (vim.fn.exists(hlgroup) == 1) and hlgroup or "",
        })

        if #data > 1 and i < #data then
          table.insert(child, { provider = "  " })
        end

        table.insert(children, child)
      end

      self[1] = self:new(children, 1)
    end,
  }
end

function M.setup()
  return {
    init = function(self)
      self.filepath = vim.api.nvim_buf_get_name(0)
      self.filetype_text = vim.bo.filetype
    end,
    hl = "HeirlineWinbar",
    M.filetype(),
    -- M.terminal(),
    M.filename(),
    M.path(),
    M.aerial(),
    Common.align(),
  }
end

return M
