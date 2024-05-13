local Conditions = require("heirline.conditions")
local Utils = require("heirline.utils")
local Common = require("plugins.heirline.common")

local M = {}

function M.mode(with_text)
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
      },
    },
    provider = function(self)
      return with_text and " %2(" .. self.mode_names[self.mode] .. "%) " or " "
    end,
    hl = function(self)
      local mode = self.mode:sub(1, 1)
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

function M.git_branch()
  return {
    condition = Conditions.is_git_repo,
    init = function(self)
      self.status_dict = vim.b.gitsigns_status_dict
    end,
    provider = function(self)
      local branch = self.status_dict.head
      if not branch or branch == "" then
        return
      end
      local icon = require("config.icons").get_icon("git", "Branch")
      return " " .. icon .. self.status_dict.head .. " "
    end,
    hl = { bg = "bright_bg" }
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
        return count > 0 and (require("config.icons").get_icon("git", "Added") .. count .. " ")
      end,
      hl = { fg = "git_add" },
    },
    {
      provider = function(self)
        local count = self.status_dict.changed or 0
        return count > 0 and (require("config.icons").get_icon("git", "Changed") .. count .. " ")
      end,
      hl = { fg = "git_change" },
    },
    {
      provider = function(self)
        local count = self.status_dict.removed or 0
        return count > 0 and (require("config.icons").get_icon("git", "Removed") .. count .. " ")
      end,
      hl = { fg = "git_del" },
    },
  }
end

function M.cmd_info()
  return {
    {
      -- macro recording
      condition = function()
        return vim.fn.reg_recording() ~= "" and vim.o.cmdheight == 0
      end,
      provider = function()
        return require("config.icons").get_icon("misc", "TS")
      end,
      hl = { fg = "orange", bold = true },
      Utils.surround({ "[", "]" }, nil, {
        provider = function()
          return vim.fn.reg_recording()
        end,
        hl = { fg = "green", bold = true },
      }),
      update = {
        "RecordingEnter",
        "RecordingLeave",
      },
      Common.space(),
    },
    {
      -- search count
      condition = function()
        return vim.v.hlsearch ~= 0 and vim.o.cmdheight == 0
      end,
      init = function(self)
        local ok, search = pcall(vim.fn.searchcount)
        if ok and search.total then
          self.search = search
        end
      end,
      provider = function(self)
        local search = self.search
        if not search then
          return
        end
        return string.format(" %d/%d", search.current, math.min(search.total, search.maxcount))
      end,
      hl = { fg = "purple", bold = true },
    },
    -- {
    --   -- showcmd
    --   condition = function()
    --     return vim.o.cmdheight == 0
    --   end,
    --   provider = ":%3.5(%S%)",
    --   -- hl = function(self)
    --   --   return { bold = true, fg = self:mode_color() }
    --   -- end,
    -- },
  }
end

function M.diagnostics()
  return {
    condition = Conditions.has_diagnostics,
    static = {
      error_icon = require("config.icons").get_icon("diagnostics", "Error"),
      warn_icon = require("config.icons").get_icon("diagnostics", "Warn"),
      hint_icon = require("config.icons").get_icon("diagnostics", "Hint"),
      info_icon = require("config.icons").get_icon("diagnostics", "Info"),
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

function M.lsp_active()
  return {
    condition = Conditions.lsp_attached,
    provider = function()
      local names = {}
      for _, server in pairs(vim.lsp.get_active_clients({ bufnr = 0 })) do
        table.insert(names, server.name)
      end
      local icon = require("config.icons").get_icon("misc", "Settings")
      return icon .. "[" .. table.concat(names, " ") .. "] "
    end,
    hl = { fg = "gray", bold = true },
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
      return "TS "
    end,
    hl = { fg = "green" },
  }
end

function M.nav()
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
      hl = { fg = "orange", bg = "bright_bg" },
    },
  }
end

function M.setup()
  return {
    fallthrough = false,
    {
      condition = function()
        return Conditions.buffer_matches({
          buftype = { "nofile", "prompt", "help", "quickfix" },
          filetype = { "^git.*", "fugitive" },
        })
      end,
      Common.filetype(),
      Common.space(),
      -- help name
      Common.align(),
    },
    -- {
    --   condition = function()
    --     return Conditions.buffer_matches({
    --       buftype = { "terminal" },
    --     })
    --   end,
    --   -- filetype
    --   -- space
    --   -- terminal name
    --   Common.align()
    -- },
    {
      condition = Conditions.is_not_active,
      {
        hl = { fg = "gray", force = true },
        -- workingdir
      },
      Common.filenameblock(),
      { provider = "%<" },
      Common.align(),
    },
    {
      M.mode(true),
      M.git_branch(),
      Common.space(),
      Common.filenameblock(),
      -- file info
      M.git_diff(),
      -- diagnostics
      Common.align(),
      M.cmd_info(),
      Common.align(),
      M.diagnostics(),
      M.lsp_active(),
      M.treesitter(),
      Common.fileencoding(),
      Common.fileformat(),
      M.nav(),
      Common.space(),
      M.mode(false),
    },
  }
end

return M
