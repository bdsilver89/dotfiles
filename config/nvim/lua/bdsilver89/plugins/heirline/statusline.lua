local Conditions = require("heirline.conditions")
local HUtils = require("heirline.utils")
local Utils = require("bdsilver89.utils")

local M = {}

function M.align()
  return {
    provider = "%="
  }
end

function M.space()
  return {
    provider = " "
  }
end

function M.vi_mode()
  return {
    init = function(self)
      self.mode = vim.fn.mode(1)
    end,
    static = {
      mode_names = {
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
      },
      mode_colors = {
        n = "blue" ,
        i = "green",
        v = "cyan",
        V =  "cyan",
        ["\22"] =  "cyan",
        c =  "orange",
        s =  "purple",
        S =  "purple",
        ["\19"] =  "purple",
        R =  "orange",
        r =  "orange",
        ["!"] =  "red",
        t =  "red",
      },
    },
    provider = function(self)
      return " %2(" .. self.mode_names[self.mode] .. "%) "
    end,
    hl = function(self)
      local mode = self.mode:sub(1,1)
      return { fg = "bg", bg = self.mode_colors[mode], bold = true }
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

function M.git_branch()
  return {
    condition = Conditions.is_git_repo,
    init = function(self)
      self.status_dict = vim.b.gitsigns_status_dict
    end,
    -- {
    --   provider = function()
    --     return Utils.ui.get_icon("separators", "LeftSlant")
    --   end,
    --   hl = { fg = "bg", bg = "statusline_bg" },
    -- },
    {
      provider = function(self)
        if self.status_dict.head == "" then
          return ""
        end

        local icon = Utils.ui.get_icon("git", "Branch")
        return icon .. (self.status_dict.head)
      end,
      hl = { fg = "gray" },
    },
    -- {
    --   provider = function()
    --     return Utils.ui.get_icon("separators", "LeftSlant")
    --   end,
    --   hl = { fg = "statusline_bg", bg = "bg" },
    -- }
  }
end

function M.git_diff()
  return {
    condition = Conditions.is_git_repo,
    init = function(self)
      self.status_dict = vim.b.gitsigns_status_dict
      self.has_changes = self.status_dict.added ~= 0 or self.status_dict.removed ~= 0 or self.status_dict.changed ~= 0
    end,
    {
      provider = function(self)
        local count = self.status_dict.added or 0
        return count > 0 and (Utils.ui.get_icon("git", "Added") .. count .. " ")
      end,
      hl = { fg = "git_add" },
    },
    {
      provider = function(self)
        local count = self.status_dict.changed or 0
        return count > 0 and (Utils.ui.get_icon("git", "Changed") .. count .. " ")
      end,
      hl = { fg = "git_change" },
    },
    {
      provider = function(self)
        local count = self.status_dict.removed or 0
        return count > 0 and (Utils.ui.get_icon("git", "Removed") .. count .. " ")
      end,
      hl = { fg = "git_del" },
    },
  }
end

function M.diagnostics()
  return {
    condition = Conditions.has_diagnostics,
    static = {
      error_icon = Utils.ui.get_icon("diagnostics", "Error"),
      warn_icon = Utils.ui.get_icon("diagnostics", "Warn"),
      hint_icon = Utils.ui.get_icon("diagnostics", "Hint"),
      info_icon = Utils.ui.get_icon("diagnostics", "Info"),
    },
    init = function(self)
      self.errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
      self.warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
      self.hints = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
      self.info = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
    end,
    update = { "DiagnosticChanged", "BufEnter" },
    {
      provider = function(self)
        return self.errors > 0 and (self.error_icon .. self.errors .. " ")
      end,
      hl = { fg = "diag_error" },
    },
    {
      provider = function(self)
        return self.warnings > 0 and (self.warn_icon .. self.warnings .. " ")
      end,
      hl = { fg = "diag_warn" },
    },
    {
      provider = function(self)
        return self.info > 0 and (self.info_icon .. self.info .. " ")
      end,
      hl = { fg = "diag_info" },
    },
    {
      provider = function(self)
        return self.hints > 0 and (self.hint_icon .. self.hints .. " ")
      end,
      hl = { fg = "diag_hint" },
    },
  }
end

function M.cmd_info()
  return {
    {
      -- macro
      condition = function()
        return vim.fn.reg_recording() ~= ""
      end,
      provider = function()
        return vim.fn.reg_recording() .. " "
      end,
      hl = { fg = "green", bold = true },
      update = { "RecordingEnter", "RecordingLeave" },
    },
    {
      -- search count
      condition = function()
        return vim.v.hlsearch ~= 0
      end,
      init = function(self)
        local ok, search = pcall(vim.fn.searchcount)
        if ok and search.total then
          self.search = search
        end
      end,
      provider = function(self)
        local search = self.search
        return string.format("[%d/%d]", search.current, math.min(search.total, search.maxcount)) .. " "
      end,
    },
  }
end

function M.treesitter()
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
    hl = { fg = "green" },
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

function M.fileencoding()
  return {
    provider = function()
      local enc = (vim.bo.fenc ~= "" and vim.bo.fenc) or vim.o.enc
      return enc ~= "utf-8" and enc:upper()
    end,
  }
end

function M.fileformat()
  return {
    provider = function()
      local fmt = vim.bo.fileformat
      return fmt:upper()
    end,
  }
end

function M.ruler()
  return {
    {
      -- provider = "%7(%3l/%3L%):%2c %P",
      provider = function()
        local padding_str = ("%%%dd:%%-%dd"):format(3, 2)
        local line = vim.fn.line "."
        local char = vim.fn.virtcol "."
        return padding_str:format(line, char)
      end,
    },
    M.space(),
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
  }
end

function M.scrollbar()
  return {
    static = {
      sbar = { '▁', '▂', '▃', '▄', '▅', '▆', '▇', '█' }
    },
    provider = function(self)
      local curr_line = vim.api.nvim_win_get_cursor(0)[1]
      local lines = vim.api.nvim_buf_line_count(0)
      local i = math.floor((curr_line - 1) / lines * #self.sbar) + 1
      return string.rep(self.sbar[i], 2)
    end,
    hl = { fg = "blue", bg = "bright_bg" },
  }
end

function M.nav()
  return {
    M.ruler(),
    M.space(),
    M.scrollbar(),
  }
end

function M.special_statusline()
  return {
    condition = function()
      return Conditions.buffer_matches({
        buftype = { "nofile", "prompt", "help", "quickfix" },
        filetype = { "^git.*", "fugitive" },
      })
    end,
    M.filetype(),
    M.space(),
    {
      condition = function()
        return vim.bo.filetype == "help"
      end,
      provider = function()
        local filename = vim.api.nvim_buf_get_name(0)
        return vim.fn.fnamemodify(filename, ":t")
      end,
      hl = { fg = "blue" },
    },
    M.align(),
  }
end

function M.terminal_statusline()
  return {
    condition = function()
      return Conditions.buffer_matches({
        buftype = { "terminal" },
      })
    end,
    {
      condition = Conditions.is_active,
      M.vi_mode(),
      M.space(),
    },
    -- TODO: Filetype
    -- TODO: space
    {
      provider = function()
        local tname, _ = vim.api.nvim_buf_get_name(0):gsub(".*:", "")
        return Utils.ui.get_icon("misc", "Terminal") .. tname
      end,
      hl = { fg = "blue", bold = true },
    },
    M.align(),
  }

end
function M.inactive_statusline()
  return {
    condition = Conditions.is_not_active,
    M.filetype(),
    M.space(),
    M.filename(),
    M.align(),
  }
end

function M.default_statusline()
  return {
    M.vi_mode(),
    M.space(),
    M.git_branch(),
    M.space(),
    M.filenameblock(),
    M.space(),
    M.git_diff(),
    M.align(),
    -- navic,
    -- dap
    M.align(),
    -- lsp active
    -- M.space(),
    -- lsp messages
    -- M.space(),
    -- ulttest
    -- M.space(),
    M.diagnostics(),
    M.cmd_info(),
    M.treesitter(),
    -- M.spell(),
    M.space(),
    {
      -- M.filetype(),
      -- M.space(),
      M.fileencoding(),
      M.fileformat(),
    },
    M.space(),
    M.nav(),
  }
end

function M.setup()
  return {
    hl = function()
      if Conditions.is_active() then
        return "StatusLine"
      else
        return "StatusLineNC"
      end
    end,
    fallthrough = false,
    M.special_statusline(),
    M.terminal_statusline(),
    M.inactive_statusline(),
    M.default_statusline(),
  }
end

return M
