local conditions = require("heirline.conditions")
local utils = require("heirline.utils")

local Align = { provider = "%=" }
local Space = { provider = " " }
local Truncate = { provider = "%<" }

local ViMode = {
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
    mode_colors = {
      n = "red",
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
    return " %2(" .. self.mode_names[self.mode] .. "%)"
  end,
  hl = function(self)
    local mode = self.mode:sub(1, 1)
    return { fg = self.mode_colors[mode], bold = true }
  end,
  update = {
    "ModeChanged",
    pattern = "*:*",
    callback = vim.schedule_wrap(function()
      vim.cmd("redrawstatus")
    end),
  },
}

ViMode = utils.surround({ "", "" }, "bright_bg", { ViMode })

local FileNameBlock = {
  init = function(self)
    self.filename = vim.api.nvim_buf_get_name(0)
  end,
}

local FileIcon = {
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

local FileName = {
  provider = function(self)
    local filename = vim.fn.fnamemodify(self.filename, ":.")
    if filename == "" then
      return "[No Name]"
    end
    if not conditions.width_percent_below(#filename, 0.25) then
      filename = vim.fn.pathshorten(filename)
    end
    return filename
  end,
  hl = { fg = utils.get_highlight("Directory").fg },
}

local FileFlags = {
  {
    condition = function()
      return vim.bo.modified
    end,
    provider = "[+]",
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

local FileNameModifier = {
  hl = function()
    if vim.bo.modified then
      return { fg = "cyan", bold = true, force = true }
    end
  end,
}

FileNameBlock = utils.insert(FileNameBlock, FileIcon, utils.insert(FileNameModifier, FileName), FileFlags, Truncate)

local Git = {
  condition = conditions.is_git_repo,
  init = function(self)
    self.status_dict = vim.b.gitsigns_status_dict
    self.has_changes = self.status_dict.added ~= 0 or self.status_dict.removed ~= 0 or self.status_dict.changed ~= 0
  end,
  hl = { fg = "orange" },
  {
    provider = function(self)
      return " " .. self.status_dict.head
    end,
    hl = { bold = true },
  },
  {
    condition = function(self)
      return self.has_changes
    end,
    provider = "(",
  },
  {
    provider = function(self)
      local count = self.status_dict.added or 0
      return count > 0 and ("+" .. count)
    end,
    hl = { fg = "git_add" },
  },
  {
    provider = function(self)
      local count = self.status_dict.removed or 0
      return count > 0 and ("-" .. count)
    end,
    hl = { fg = "git_del" },
  },
  {
    provider = function(self)
      local count = self.status_dict.changed or 0
      return count > 0 and ("~" .. count)
    end,
    hl = { fg = "git_change" },
  },
  {
    condition = function(self)
      return self.has_changes
    end,
    provider = ")",
  },
  on_click = {
    callback = function()
      vim.defer_fn(function()
        vim.cmd("Lazygit")
      end, 100)
    end,
    name = "heirline_git",
  },
}

-- local Diagnostics = {
--   condition = conditions.has_diagnostics,
--   static = {
--     error_icon = vim.fn.sign_getdefined("DiagnosticSignError")[1].text or "E",
--     warn_icon = vim.fn.sign_getdefined("DiagnosticSignWarn")[1].text or "W",
--     info_icon = vim.fn.sign_getdefined("DiagnosticSignInfo")[1].text or "I",
--     hint_icon = vim.fn.sign_getdefined("DiagnosticSignHint")[1].text or "H",
--   },
--
--   init = function(self)
--     self.errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
--     self.warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
--     self.hints = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
--     self.info = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
--   end,
--
--   update = { "DiagnosticChanged", "BufEnter" },
--
--   {
--     provider = "![",
--   },
--   {
--     provider = function(self)
--       -- 0 is just another output, we can decide to print it or not!
--       return self.errors > 0 and (self.error_icon .. self.errors .. " ")
--     end,
--     hl = { fg = "diag_error" },
--   },
--   {
--     provider = function(self)
--       return self.warnings > 0 and (self.warn_icon .. self.warnings .. " ")
--     end,
--     hl = { fg = "diag_warn" },
--   },
--   {
--     provider = function(self)
--       return self.info > 0 and (self.info_icon .. self.info .. " ")
--     end,
--     hl = { fg = "diag_info" },
--   },
--   {
--     provider = function(self)
--       return self.hints > 0 and (self.hint_icon .. self.hints)
--     end,
--     hl = { fg = "diag_hint" },
--   },
--   {
--     provider = "]",
--   },
-- }

local DapMessages = {
  -- condition = function()
  --   local session = require("dap").session()
  --   return session ~= nil
  -- end,
  -- provider = function()
  --   return " " .. require("dap").status()
  -- end,
  hl = "Debug",
}

local LSPMessages = {
  provider = "",
  -- provider = require("lsp-status").status,
  hl = { fg = "gray" },
}

local LSPActive = {
  condition = conditions.lsp_attached,
  update = { "LspAttach", "LspDetach" },
  provider = function()
    local names = {}
    for _, server in pairs(vim.lsp.get_clients({ bufnr = 0 })) do
      table.insert(names, server.name)
    end
    return " [" .. table.concat(names, " ") .. "]"
  end,
  hl = { fg = "green", bold = true },
}

local FileType = {
  provider = function()
    return string.upper(vim.bo.filetype)
  end,
  hl = { fg = utils.get_highlight("Type").fg, bold = true },
}

local FileEncoding = {
  provider = function()
    return (vim.bo.fenc ~= "" and vim.bo.fenc) or vim.o.enc
  end,
}

local FileFormat = {
  provider = function()
    return vim.bo.fileformat
  end,
}

local Ruler = {
  provider = "%7(%l/%3L%):%2c %P",
}

local ScrollBar = {
  static = {
    sbar = { "▁", "▂", "▃", "▄", "▅", "▆", "▇", "█" },
  },
  provider = function(self)
    local curr_line = vim.api.nvim_win_get_cursor(0)[1]
    local lines = vim.api.nvim_buf_line_count(0)
    local i = math.floor((curr_line - 1) / lines * #self.sbar) + 1
    return string.rep(self.sbar[i], 2)
  end,
  hl = { fg = "blue", bg = "bright_bg" },
}

local TerminalName = {
  provider = function()
    local tname, _ = vim.api.nvim_buf_get_name(0):gsub(".*:", "")
    return " " .. tname
  end,
  hl = { fg = "blue", bold = true },
}

local HelpFileName = {
  condition = function()
    return vim.bo.filetype == "help"
  end,
  provider = function()
    local filename = vim.api.nvim_buf_get_name(0)
    return vim.fn.fnamemodify(filename, ":t")
  end,
  hl = { fg = "blue" },
}

local DefaultStatusline = {
  ViMode,
  Space,
  FileNameBlock,
  Truncate,
  Space,
  Git,
  Space,
  -- Diagnostics,
  Align,
  -- navic
  Align,
  DapMessages,
  LSPMessages,
  Align,
  LSPActive,
  Space,
  FileType,
  Space,
  FileEncoding,
  Space,
  FileFormat,
  Space,
  Ruler,
  -- search count
  Space,
  ScrollBar,
}

local InactiveStatusline = {
  condition = conditions.is_not_active,
  FileName,
  Truncate,
  Align,
}

local SpecialStatusline = {
  condition = function()
    return conditions.buffer_matches({ buftype = { "nofile", "prompt", "help", "quickfix" } })
  end,
  FileType,
  -- quickfix %q
  Space,
  -- helpfilename
  Align,
}

-- local GitStatusline = {
--   condition = function()
--     return conditions.buffer_matches({ filetype = { "^git.*", "fugitive" } })
--   end,
--   FileType,
--   Space,
--   -- fugitive statusline
--   Space,
--   Align,
-- }

local TerminalStatusline = {
  condition = function()
    return conditions.buffer_matches({ buftype = { "terminal" } })
  end,
  {
    conditions = conditions.is_active,
    ViMode,
    Space,
  },
  FileType,
  Space,
  TerminalName,
  Align,
  hl = {
    bg = "dark_red",
  },
}

return {
  hl = function()
    if conditions.is_active() then
      return "StatusLine"
    else
      return "StatuslineNC"
    end
  end,
  static = {
    mode_colors_map = {
      n = "red",
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
      t = "green",
    },
    mode_color = function(self)
      local mode = conditions.is_active() and vim.fn.mode() or "n"
      return self.mode_colors_map[mode]
    end,
  },
  fallthrough = false,
  -- GitStatusline,
  SpecialStatusline,
  TerminalStatusline,
  InactiveStatusline,
  DefaultStatusline,
}
