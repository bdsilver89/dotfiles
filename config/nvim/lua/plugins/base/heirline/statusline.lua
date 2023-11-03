local Conditions = require("heirline.conditions")
local Common = require("plugins.base.heirline.common")
local Icons = require("utils.icons")

local M = {}

M.filetypes = { "dashboard", "NvimTree", "^neo--tree$", "^neotoest--summary$", "^neo--tree--popup$", "toggleterm" }
M.buftypes = { "nofile", "prompt", "help", "quickfix" }
M.force_inactive_filetypes = { "aerial", "aerial-nav", "lazy", "undotree", "TelescopePrompt" }

function M.vim_mode()
  return {
    init = function(self)
      self.mode = vim.fn.mode(1)
    end,
    update = {
      "ModeChanged",
      pattern = "*:*",
      callback = vim.schedule_wrap(function()
        vim.cmd("redrawstatus")
      end),
    },
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
        c = "COMMAND",
        cv = "Ex",
        r = "...",
        rm = "M",
        ["r?"] = "?",
        ["!"] = "!",
        t = "TERM",
      },
    },
    {
      --   {
      --     provider = " ",
      --     hl = function(self)
      --       if self.mode_names[self.mode] == "NORMAL" then
      --         return "HeirlineNormal"
      --       elseif self.mode_names[self.mode] == "INSERT" then
      --         return "HeirlineInsert"
      --       elseif self.mode_names[self.mode] == "VISUAL" then
      --         return "HeirlineVisual"
      --       elseif self.mode_names[self.mode] == "REPLACE" then
      --         return "HeirlineReplace"
      --       elseif self.mode_names[self.mode] == "COMMAND" then
      --         return "HeirlineCommand"
      --       elseif self.mode_names[self.mode] == "TERM" then
      --         return "HeirlineTerminal"
      --       else
      --         return ""
      --       end
      --     end,
      --   },
      {
        provider = function(self)
          return "%2(" .. self.mode_names[self.mode] .. "%)"
        end,
      },
      {
        provider = " | ",
      },
    },
  }
end

function M.git()
  return {
    condition = Conditions.is_git_repo,
    init = function(self)
      ---@diagnostic disable-next-line: undefined-field
      self.status_dict = vim.b.gitsigns_status_dict
      self.has_changes = self.status_dict.added ~= 0 or self.status_dict.removed ~= 0 or self.status_dict.changed ~= 0
    end,
    {
      provider = function(self)
        -- return " " .. (self.status_dict.head == "" and "main" or self.status_dict.head) .. " "
        return Icons.git.branch .. (self.status_dict.head == "" and "main" or self.status_dict.head) .. " "
      end,
      hl = "Constant",
    },
    {
      provider = function(self)
        local count = self.status_dict.added or 0
        return (count > 0) and (Icons.git.added .. count .. " ")
      end,
      hl = "GitSignsAdd",
    },
    {
      provider = function(self)
        local count = self.status_dict.removed or 0
        return (count > 0) and (Icons.git.removed .. count .. " ")
      end,
      hl = "GitSignsDelete",
    },
    {
      provider = function(self)
        local count = self.status_dict.changed or 0
        return (count > 0) and (Icons.git.modified .. count .. " ")
      end,
      hl = "GitSignsChange",
    },
    {
      condition = function(self)
        return self.has_changes
      end,
      provider = "| ",
    },
  }
end

function M.diagnostics()
  return {
    init = function(self)
      self.errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
      self.warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
      self.hints = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
      self.info = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
    end,
    update = { "DiagnosticChanged", "BufEnter" },
    {
      provider = function(self)
        return self.errors > 0 and (Icons.diagnostics.Error .. self.errors .. " ")
      end,
      hl = "DiagnosticSignError",
    },
    {
      provider = function(self)
        return self.warnings > 0 and (Icons.diagnostics.Warn .. self.warnings .. " ")
      end,
      hl = "DiagnosticSignWarn",
    },
    {
      provider = function(self)
        return self.info ~= 0 and (Icons.diagnostics.Info .. self.info .. " ")
      end,
      hl = "DiagnosticSignInfo",
    },
    {
      provider = function(self)
        return self.hints ~= 0 and (Icons.diagnostics.Hint .. self.hints .. " ")
      end,
      hl = "DiagnosticSignHint",
    },
    {
      condition = function(self)
        return self.errors ~= 0 or self.warnings ~= 0 or self.info ~= 0 or self.hints ~= 0
      end,
      provider = "| ",
    },
  }
end

-- function M.lsp_attached()
--   return {
--     condition = Conditions.lsp_attached,
--     static = {
--       lsp_attached = false,
--       show_lsp = {},
--     },
--     init = function(self)
--       for i, server in pairs(vim.lsp.get_active_clients({ bufnr = 0 })) do
--         if self.show_lsp[server] ~= false then
--           self.lsp_attached = true
--         end
--       end
--     end,
--     update = { "LspAttach", "LspDetach" },
--     {
--       condition = function(self)
--         return self.lsp_attached
--       end,
--       provider = Icons.misc.lsp,
--     },
--     on_click = {
--       name = "lsp_click",
--       callback = function()
--         vim.schedule_wrap(function()
--           vim.cmd("LspInfo")
--         end)
--       end,
--     },
--   }
-- end

function M.file_encoding()
  return {
    condition = function()
      return not Conditions.buffer_matches({
        filetype = M.filetypes,
      })
    end,
    {
      provider = function()
        local enc = (vim.bo.fenc ~= "" and vim.bo.fenc) or vim.o.enc
        return " " .. enc
      end,
    },
    {
      provider = " | ",
    },
  }
end

function M.macro_recording()
  return {
    condition = function()
      return vim.fn.reg_recording() ~= ""
    end,
    update = {
      "RecordingEnter",
      "RecordingLeave",
    },
    {
      provider = function()
        return vim.fn.reg_recording()
      end,
      hl = "Macro",
    },
    {
      provider = " | ",
    },
  }
end

function M.file_size()
  return {
    static = {
      suffix = { "b", "k", "M", "G", "T", "P", "E" },
    },
    {
      provider = function(self)
        local fsize = vim.fn.getfsize(vim.api.nvim_buf_get_name(0))
        fsize = (fsize < 0 and 0) or fsize
        if fsize <= 0 then
          return "0" .. self.suffix[1]
        end
        local i = math.floor((math.log(fsize) / math.log(1024)))
        return string.format("%.2g%s", fsize / math.pow(1024, i), self.suffix[i + 1])
      end,
    },
    {
      provider = " | ",
    },
  }
end

function M.search_results()
  return {
    condition = function()
      return vim.v.hlsearch ~= 0
    end,
    init = function(self)
      local ok, search = pcall(vim.fn.searchcount)
      if ok and search.total then
        self.search = search
      end
    end,
    {
      provider = function(self)
        local search = self.search
        return string.format("%d/%d", search.current, math.min(search.total, search.maxcount))
      end,
      -- hl = "Substitute",
    },
    {
      provider = " | ",
    },
  }
end

function M.ruler()
  return {
    static = {
      sbar = { "▁", "▂", "▃", "▄", "▅", "▆", "▇", "█" },
    },
    init = function(self)
      self.current_line = vim.fn.line(".")
      self.current_char = vim.fn.virtcol(".")
      self.line_count = vim.fn.line("$")
    end,
    {
      provider = function(self)
        return string.format("%3d:%-2d", self.current_line, self.current_char) .. " "
      end,
    },
    {
      provider = function(self)
        local i = math.floor((self.current_line - 1) / self.line_count * #self.sbar) + 1
        if self.sbar[i] then
          return string.rep(self.sbar[i], 2) .. " "
        end
        return ""
      end,
    },
    {
      provider = function(self)
        local text = "%2p%%"
        if self.current_line == 1 then
          text = "Top"
        elseif self.current_line == self.line_count then
          text = "Bot"
        end
        return text .. " "
      end,
    },
  }
end

function M.setup()
  return {
    static = {
      filetypes = M.filetypes,
      buftypes = M.buftypes,
      force_inactive_filetypes = M.force_inactive_filetypes,
    },
    condition = function(self)
      return not Conditions.buffer_matches({
        filetype = self.force_inactive_filetypes,
      })
    end,
    M.vim_mode(),
    M.git(),
    M.diagnostics(),
    -- -- M.filename.lua
    -- M.lsp_attached(),
    Common.align(),
    -- M.overseer,
    -- M.dap,
    -- M.lazy,
    -- M.filetype(),
    M.macro_recording(),
    M.file_encoding(),
    M.file_size(),
    -- M.session(),
    M.search_results(),
    M.ruler(),
  }
end

return M
