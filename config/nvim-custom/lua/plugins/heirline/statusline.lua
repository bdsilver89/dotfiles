local Common = require("plugins.heirline.common")

local M = {}

local mode_names = {
  n = "NORMAL",
  no = "NORMAL",
  nov = "NORMAL",
  noV = "NORMAL",
  ["no\22"] = "NORMAL",
  niI = "NORMAL",
  niR = "NORMAL",
  niV = "NORMAL",
  nt = "NORMAL",
  v = "VISUAL",
  vs = "VISUAL",
  V = "VISUAL",
  Vs = "VISUAL",
  ["\22"] = "VISUAL",
  ["\22s"] = "VISUAL",
  s = "SELECT",
  S = "SELECT",
  ["\19"] = "SELECT",
  i = "INSERT",
  ic = "INSERT",
  ix = "INSERT",
  R = "REPLACE",
  Rc = "REPLACE",
  Rx = "REPLACE",
  Rv = "REPLACE",
  Rvc = "REPLACE",
  Rvx = "REPLACE",
  c = "CCOMMAND",
  cv = "Ex",
  r = "...",
  rm = "M",
  ["r?"] = "?",
  ["!"] = "!",
  t = "TERM",
}

local mode_colors = {
  n = "blue",
  i = "green",
  v = "cyan",
  V = "cyan",
  ["\22"] = "cyan",
  c = "orange",
  s = "purple",
  S = "purple",
  ["\19"] = "purple",
  R = "orange",
  r = "orange",
  ["!"] = "red",
  t = "red",
}

local function mode(with_text)
  return {
    init = function(self)
      self.mode = vim.fn.mode(1)
    end,
    static = {},
    provider = function(self)
      return with_text and " %2(" .. mode_names[self.mode] .. "%) " or " "
    end,
    hl = function(self)
      return {
        fg = "bg",
        bg = mode_colors[self.mode:sub(1, 1)],
        bold = true,
      }
    end,
    update = {
      "ModeChanged",
      pattern = "*:*",
      callback = vim.schedule_wrap(function()
        vim.cmd.redrawstatus()
      end),
    },
  }
end

local function git()
  return {
    condition = function()
      return require("heirline.conditions").is_git_repo()
    end,
    init = function(self)
      self.mode = vim.fn.mode(1)
      self.status_dict = vim.b.gitsigns_status_dict
      self.added = self.status_dict.added or 0
      self.removed = self.status_dict.removed or 0
      self.changed = self.status_dict.changed or 0

      self.has_changes = self.added ~= 0 or self.removed ~= 0 or self.changed ~= 0
    end,

    -- branch
    {
      provider = function(self)
        local branch = self.status_dict.head
        if not branch or branch == "" then
          return
        end
        if vim.g.enable_icons then
          local icon = require("mini.icons").get("filetype", "git")
          return " " .. icon .. " " .. self.status_dict.head
        else
          return " " .. self.status_dict.head
        end
      end,
      hl = function(self)
        return {
          -- bg = "bright_bg",
          fg = mode_colors[self.mode:sub(1, 1)],
          bold = true,
        }
      end,
    },

    {
      condition = function(self)
        return self.has_changes
      end,
      Common.space(),
    },

    -- diff
    {
      condition = function(self)
        return self.has_changes and not vim.g.enable_icons
      end,
      provider = " (",
    },
    {
      condition = function(self)
        return self.added ~= 0
      end,
      provider = function(self)
        return (vim.g.enable_icons and " " or "+") .. self.added .. (vim.g.enable_icons and " " or "")
      end,
      hl = { fg = "git_add" },
    },
    {
      condition = function(self)
        return self.removed ~= 0
      end,
      provider = function(self)
        return (vim.g.enable_icons and " " or "-") .. self.removed .. (vim.g.enable_icons and " " or "")
      end,
      hl = { fg = "git_del" },
    },
    {
      condition = function(self)
        return self.changed ~= 0
      end,
      provider = function(self)
        return (vim.g.enable_icons and " " or "~") .. self.changed
      end,
      hl = { fg = "git_change" },
    },
    {
      condition = function(self)
        return self.has_changes and not vim.g.enable_icons
      end,
      provider = ")",
    },
    Common.space(),
    hl = { bg = "bright_bg" },
  }
end

local function diagnostics()
  return {
    condition = function()
      return require("heirline.conditions").has_diagnostics()
    end,
    update = { "DiagnosticChanged", "BufEnter" },
    init = function(self)
      self.diagnostics = vim.diagnostic.count()
    end,
    {
      provider = function(self)
        return self.diagnostics[1] and ((vim.g.enable_icons and " " or "E") .. self.diagnostics[1] .. " ")
      end,
      hl = "DiagnosticError",
    },
    {
      provider = function(self)
        return self.diagnostics[2] and ((vim.g.enable_icons and " " or "W") .. self.diagnostics[2] .. " ")
      end,
      hl = "DiagnosticWarn",
    },
    {
      provider = function(self)
        return self.diagnostics[3] and ((vim.g.enable_icons and " " or "I") .. self.diagnostics[3] .. " ")
      end,
      hl = "DiagnosticInfo",
    },
    {
      provider = function(self)
        return self.diagnostics[4] and ((vim.g.enable_icons and " " or "H") .. self.diagnostics[4] .. " ")
      end,
      hl = "DiagnosticHint",
    },
  }
end

local function fileflags()
  return {
    {
      condition = function()
        return vim.bo.modified
      end,
      provider = require("config.icons").get_icon("misc", "Modified"),
      hl = { fg = "green" },
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

local function fileicon()
  return {
    init = function(self)
      local has_devicons, devicons = pcall(require, "nvim-web-devicons")
      if has_devicons then
        self.icon, self.icon_color =
          devicons.get_icon_color(self.filename, vim.fn.fnamemodify(self.filename, ":e"), { default = true })
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
    -- fileicon(),
    filename(),
    Common.space(),
    -- fileflags(),
    -- hl = { bg = "bright_bg" },
  }
end

local function cmd_info()
  return {
    -- macro recording
    {
      condition = function()
        return vim.fn.reg_recording ~= ""
      end,
      provider = function()
        local register = vim.fn.reg_recording()
        if register ~= "" then
          register = "@" .. register
        end
        return register
      end,
      hl = { fg = "orange" },
      update = { "RecordingEnter", "RecordingLeave" },
    },

    -- search_count
    {
      condition = function()
        return vim.v.hlsearch ~= 0
      end,
      provider = function()
        local search_ok, search = pcall(vim.fn.searchcount)
        if search_ok and type(search) == "table" and search.total then
          return ("%s%d/%s%d"):format(
            search.current > search.maxcount and ">" or "",
            math.min(search.current, search.maxcount),
            search.incomplete == 2 and ">" or "",
            math.min(search.total, search.maxcount)
          )
        end
      end,
    },

    -- show cmd
    {
      condition = function()
        return vim.opt.showcmdloc:get() == "statusline"
      end,
      provider = function()
        local minwid = 0
        local maxwid = 5
        return ("%%%d.%d(%%S%%)"):format(minwid, maxwid)
      end,
    },
  }
end

local function fileformat()
  return {
    {
      provider = function()
        -- return string.upper(vim.bo.fileencoding)
        return vim.bo.fileencoding
      end,
    },
    Common.space(),
    {
      provider = function()
        -- return string.upper(vim.bo.fileformat)
        return vim.bo.fileformat
      end,
    },
  }
end

local function filetype()
  return {
    init = function(self)
      local icon, hl = require("mini.icons").get("filetype", vim.bo.filetype)
      self.icon = icon
      self.hl = hl
    end,
    provider = function(self)
      return (vim.g.enable_icons and (self.icon .. " ") or "") .. vim.bo.filetype
    end,
    hl = function(self)
      return { fg = self.hl }
    end,
  }
end

local function filesize()
  return {
    static = {
      suffix = { "b", "k", "M", "G", "T", "P", "E" },
    },
    provider = function(self)
      local fsize = vim.fn.getfsize(vim.api.nvim_buf_get_name(0))
      fsize = (fsize < 0 and 0) or fsize
      if fsize <= 0 then
        return "0" .. self.suffix[1]
      end
      local i = math.floor((math.log(fsize) / math.log(1024)))
      return string.format("%.2g%s", fsize / math.pow(1024, i), self.suffix[i + 1])
    end,
  }
end

local function lsp_active()
  return {
    condition = function()
      return require("heirline.conditions").lsp_attached()
    end,
    provider = function()
      local names = {}
      for _, server in pairs(vim.lsp.get_clients({ bufnr = 0 })) do
        table.insert(names, server.name)
      end
      -- local icon = require("config.icons").get_icon("misc", "Settings")
      return "[" .. table.concat(names, " ") .. "] "
    end,
    hl = { fg = "gray", bold = true }, -- , bg = "bright_bg" },
  }
end

local function treesitter()
  return {
    condition = function(self)
      local bufnr = vim.api.nvim_get_current_buf() or 0
      local ft = vim.bo[bufnr].filetype
      local lang = vim.treesitter.language.get_lang(ft)
      local has_parser, _ = pcall(vim.treesitter.get_string_parser, "", lang)
      if not has_parser and vim.fn.has("nvim-0.10") == 0 then
        ft = vim.split(ft, ".", { plain = true })[1]
        lang = vim.treesitter.language.get_lang(ft) or ft
        has_parser, _ = pcall(vim.treesitter.get_string_parser, "", lang)
      end
      self.has_parser = has_parser
      return has_parser
    end,
    provider = function()
      return "TS"
    end,
    hl = { fg = "green" }, -- bg = "bright_bg" },
  }
end

local function filemetadata()
  return {
    {
      provider = "[",
    },
    fileformat(),
    Common.space(),
    filetype(),
    Common.space(),
    treesitter(),
    -- filesize(),
    {
      provider = "]",
    },
    -- hl = { bg = "bright_bg" },
  }
end

local function nav()
  return {
    {
      provider = function()
        local padding_str = ("%%%dd:%%-%dd"):format(3, 2)
        local line = vim.fn.line(".")
        local char = vim.fn.virtcol(".")
        return padding_str:format(line, char) .. " "
      end,
    },
    {
      provider = function()
        local text = "%2p%%"
        local current_line = vim.fn.line(".")
        if current_line == 1 then
          text = "Top"
        elseif current_line == vim.fn.line("$") then
          text = "Bot"
        end
        return text
      end,
    },
    Common.space(),
    {
      static = {
        sbar = { "▁", "▂", "▃", "▄", "▅", "▆", "▇", "█" },
      },
      provider = function(self)
        local curr_line = vim.api.nvim_win_get_cursor(0)[1]
        local lines = vim.api.nvim_buf_line_count(0)
        local i = math.floor((curr_line - 1) / lines * #self.sbar) + 1
        return string.rep(self.sbar[i], 2)
      end,
      hl = { fg = "orange" },
    },
  }
end

function M.setup()
  return {
    fallthrough = false,

    -- special statusline
    {
      condition = function()
        require("heirline.conditions").buffer_matches({
          buftype = { "nofile", "prompt", "help", "quickfix" },
          filetype = { "^git.*", "fugitive", "^Neogit.*" },
        })
      end,
      Common.align(),
    },

    -- inactive statusline
    {
      condition = function()
        return require("heirline.conditions").is_not_active()
      end,
      Common.align(),
    },

    -- normal statusline
    {
      mode(true),
      git(),
      Common.space(),
      filenameblock(),
      Common.align(),
      cmd_info(),
      Common.align(),
      diagnostics(),
      lsp_active(),
      filemetadata(),
      Common.space(),
      nav(),
      Common.space(),
      mode(),
    },
  }
end

return M
