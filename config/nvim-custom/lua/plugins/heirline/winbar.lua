local Common = require("plugins.heirline.common")

local M = {}

-- local sep = "  "
local sep = " / "

local function breadcrumbs()
  return {
    init = function(self)
      local has_trouble, trouble = pcall(require, "trouble")
      self.has_trouble = has_trouble
      if has_trouble then
        self.symbols = trouble.statusline({
          mode = "lsp_document_symbols",
          groups = {},
          title = false,
          filter = { range = true },
        })
      end
    end,
    condition = function(self)
      return self.has_trouble and self.symbols.has
    end,
    provider = function(self)
      return self.symbols.get()
    end,
  }
end

local function filepath()
  return {
    init = function(self)
      self.filepath = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":h")
      self.short_path = vim.fn.fnamemodify(vim.fn.expand("%:h"), ":h")

      -- self.filepath = vim.fn.fnamemodify(self.current_dir, self.modifiers.dirname or nil)
      -- self.short_path = vim.fn.fnamemodify(vim.fn.expand("%:h"), self.modifiers.dirname or nil)
      if self.filepath == "" then
        self.filepath = "[No Name]"
      end
    end,
    hl = "HeirlineWinbar",
    {
      condition = function(self)
        return self.filepath ~= "."
      end,
      -- on_click = {
      --   callback = function(self)
      --     require("telescope.builtin").find_files({
      --       cwd = self.current_dir,
      --     })
      --   end,
      --   name = "wb_path_click",
      -- },
      flexible = 2,
      {
        provider = function(self)
          -- return table.concat(vim.fn.split(self.filepath, "/"), sep) .. sep
          return self.filepath
        end,
      },
      {
        provider = function(self)
          -- local filepath = vim.fn.pathshorten(self.short_path)
          -- return table.concat(vim.fn.split(self.short_path, "/"), sep) .. sep
          return self.short_path
        end,
      },
      {
        provider = "",
      },
    },
  }
end

-- function M.filename()
--   return {
--     {
--       -- icon
--       {
--         init = function(self)
--           local devicons_avail, devicons = pcall(require, "nvim-web-devicons")
--           if devicons_avail then
--             self.filetype_icon, self.filetype_hl = devicons.get_icon_by_filetype(vim.bo.filetype)
--           end
--         end,
--         provider = function(self)
--           return self.filetype_icon and self.filetype_icon .. " " or ""
--         end,
--         hl = function(self)
--           return self.filetype_hl
--         end,
--       },
--
--       -- name
--       {
--         provider = function()
--           return vim.fn.expand("%:t") .. " "
--         end,
--         hl = { fg = "fg" },
--       },
--       hl = "HeirlineWinbar",
--     },
--     {
--       condition = function()
--         return vim.bo.modified
--       end,
--       provider = require("config.icons").get_icon("misc", "Modified"),
--       hl = { fg = "green" },
--     },
--     {
--       condition = function()
--         return not vim.bo.modifiable or vim.bo.readonly
--       end,
--       provider = require("config.icons").get_icon("misc", "Readonly"),
--       hl = { fg = "orange" },
--     },
--   }
-- end

local function fileflags()
  return {
    {
      condition = function()
        return vim.bo.modified
      end,
      {
        condition = function()
          return vim.g.enable_icons
        end,
        provider = "●",
      },
      {
        condition = function()
          return not vim.g.enable_icons
        end,
        provider = "[+]",
      },
      hl = { fg = "orange" },
    },
    {
      condition = function()
        return (not vim.bo.modifiable or vim.bo.readonly)
      end,
      {
        condition = function()
          return vim.g.enable_icons
        end,
        provider = "",
      },
      {
        condition = function()
          return not vim.g.enable_icons
        end,
        provider = "[L]",
      },
      hl = { fg = "red" },
    },
  }
end

local function fileicon()
  return {
    init = function(self)
      -- local has_devicons, devicons = pcall(require, "nvim-web-devicons")
      -- if has_devicons then
      --   self.icon, self.icon_color =
      --     devicons.get_icon_color(self.filename, vim.fn.fnamemodify(self.filename, ":e"), { default = true })
      -- end
      local icon, hl = require("mini.icons").get("filetype", vim.bo.filetype)
      self.icon = icon
      self.hl = hl
    end,
    provider = function(self)
      return self.icon
    end,
    hl = function(self)
      return { fg = self.hl }
      -- return self.icon_color and { fg = self.icon_color }
    end,
  }
end

local function filename()
  return {
    init = function(self)
      self.lfilename = vim.fn.fnamemodify(self.filename, ":.")
      if self.lfilename == "" then
        self.lfilename = "[No Name]"
      end
      if not require("heirline.conditions").width_percent_below(#self.lfilename, 0.27) then
        self.lfilename = vim.fn.pathshorten(self.lfilename)
      end
    end,
    flexible = 2,
    {
      provider = function(self)
        return self.lfilename .. " "
      end,
    },
    {
      provider = function(self)
        return vim.fn.pathshorten(self.lfilename)
      end,
    },
  }
end

local function filenameblock()
  return {
    init = function(self)
      self.filename = vim.api.nvim_buf_get_name(0)
    end,
    condition = function()
      return not require("heirline.conditions").buffer_matches({
        filetype = { "^oil$" },
      })
    end,
    fileicon(),
    Common.space(),
    filename(),
    fileflags(),
  }
end

local function oil_path()
  return {
    condition = function()
      return require("heirline.conditions").buffer_matches({
        filetype = { "^oil$" },
      })
    end,
    provider = function()
      local path = require("oil").get_current_dir()
      return path
    end,
  }
end

function M.setup()
  return {
    -- breadcrumbs(),
    { provider = "%<" },
    { provider = "%=" },
    -- oil_path(),
    filenameblock(),
    hl = "HeirlineWinbar",
  }
end

return M
