local icons = require("icons")

local M = {}

---@type table<string, boolean>
local statusline_hls = {}

---@param hl string
---@return string
function M.get_or_create_hl(hl)
  local hl_name = "Statusline" .. hl
  if not statusline_hls[hl] then
    local bg_hl = vim.api.nvim_get_hl(0, { name = "Statusline" })
    local fg_hl = vim.api.nvim_get_hl(0, { name = hl })
    vim.api.nvim_set_hl(0, hl_name, { bg = ("#%06x"):format(bg_hl.bg), fg = ("#%06x"):format(fg_hl.fg) })
    statusline_hls[hl] = true
  end
  return hl_name
end

---@type table<string, boolean>
local mode_hls = {}

---@type table<string, string>
local mode_source_hl = {
  Normal = "Function",
  Pending = "Constant",
  Visual = "Special",
  Insert = "String",
  Replace = "DiagnosticError",
  Command = "Statement",
  Other = "Comment",
}

---Creates (and caches) StatuslineMode<hl> / StatuslineModeSeparator<hl> highlight
---groups, filling in the bg/fg that mode_component's literal %#...# refs assume
---already exist.
---@param hl string
local function get_or_create_mode_hl(hl)
  if mode_hls[hl] then
    return
  end

  local source = mode_source_hl[hl] or mode_source_hl.Other
  local bg_hl = vim.api.nvim_get_hl(0, { name = "Statusline" })
  local fg_hl = vim.api.nvim_get_hl(0, { name = source })

  local base_bg = bg_hl.bg and ("#%06x"):format(bg_hl.bg) or "NONE"
  local accent = fg_hl.fg and ("#%06x"):format(fg_hl.fg) or "NONE"

  -- filled "pill" for the mode text: accent color as bg, statusline bg as fg
  vim.api.nvim_set_hl(0, "StatuslineMode" .. hl, { fg = base_bg, bg = accent, bold = true })
  -- separator either side of the pill: accent color as fg on the plain statusline bg
  vim.api.nvim_set_hl(0, "StatuslineModeSeparator" .. hl, { fg = accent, bg = base_bg })

  mode_hls[hl] = true
end

---@return string
function M.mode_component()
  local mode_to_str = {
    ["n"] = "NORMAL",
    ["no"] = "OP-PENDING",
    ["nov"] = "OP-PENDING",
    ["noV"] = "OP-PENDING",
    ["no\22"] = "OP-PENDING",
    ["niI"] = "NORMAL",
    ["niR"] = "NORMAL",
    ["niV"] = "NORMAL",
    ["nt"] = "NORMAL",
    ["ntT"] = "NORMAL",
    ["v"] = "VISUAL",
    ["vs"] = "VISUAL",
    ["V"] = "VISUAL",
    ["Vs"] = "VISUAL",
    ["\22"] = "VISUAL",
    ["\22s"] = "VISUAL",
    ["s"] = "SELECT",
    ["S"] = "SELECT",
    ["\19"] = "SELECT",
    ["i"] = "INSERT",
    ["ic"] = "INSERT",
    ["ix"] = "INSERT",
    ["R"] = "REPLACE",
    ["Rc"] = "REPLACE",
    ["Rx"] = "REPLACE",
    ["Rv"] = "VIRT REPLACE",
    ["Rvc"] = "VIRT REPLACE",
    ["Rvx"] = "VIRT REPLACE",
    ["c"] = "COMMAND",
    ["cv"] = "VIM EX",
    ["ce"] = "EX",
    ["r"] = "PROMPT",
    ["rm"] = "MORE",
    ["r?"] = "CONFIRM",
    ["!"] = "SHELL",
    ["t"] = "TERMINAL",
  }

  local mode = mode_to_str[vim.api.nvim_get_mode().mode] or "UNKNOWN"

  local hl = "Other"
  if mode:find("NORMAL") then
    hl = "Normal"
  elseif mode:find("PENDING") then
    hl = "Pending"
  elseif mode:find("VISUAL") then
    hl = "Visual"
  elseif mode:find("INSERT") or mode:find("SELECT") then
    hl = "Insert"
  elseif mode:find("REPLACE") then
    hl = "Replace"
  elseif mode:find("COMMAND") or mode:find("TERMINAL") or mode:find("EX") then
    hl = "Command"
  end

  get_or_create_mode_hl(hl)
  return table.concat({
    string.format("%%#StatuslineModeSeparator%s#", hl),
    string.format("%%#StatuslineMode%s#%s", hl, mode),
    string.format("%%#StatuslineModeSeparator%s#", hl),
  })
end

---@return string
function M.filetype_component()
  local has_devicons, devicons = pcall(require, "nvim-web-devicons")

  local special_icons = {
    fzf = { icons.misc.terminal, "Special" },
    gitcommit = { icons.misc.git, "Number" },
    gitrebase = { icons.misc.git, "Number" },
    qf = { icons.misc.search, "Conditional" },
  }

  local filetype = vim.bo.filetype
  if filetype == "" then
    filetype = "[No Name]"
  end

  local icon, icon_hl = "", "Normal"
  if special_icons[filetype] then
    icon, icon_hl = unpack(special_icons[filetype])
  elseif has_devicons then
    local buf_name = vim.api.nvim_buf_get_name(0)
    local name = vim.fn.fnamemodify(buf_name, ":t")
    local ext = vim.fn.fnamemodify(buf_name, ":e")

    icon, icon_hl = devicons.get_icon(name, ext)
    if not icon then
      icon, icon_hl = devicons.get_icon_by_filetype(filetype, { default = true })
    end
  end
  icon_hl = M.get_or_create_hl(icon_hl)

  return string.format("%%#%s#%s %%#StatuslineTitle#%s", icon_hl, icon, filetype)
end

---@return string
function M.git_component()
  local head = vim.b.gitsigns_head
  if not head or head == "" then
    return ""
  end

  local component = string.format(" %s", head)

  local status_dict = vim.b.gitsigns_status_dict
  if not status_dict then
    return component
  end

  local status = ""
  local added = status_dict.added or 0
  local changed = status_dict.changed or 0
  local removed = status_dict.removed or 0

  if added > 0 then
    status = string.format("+%d", added)
  end
  if changed > 0 then
    status = status .. string.format("~%d", changed)
  end
  if removed > 0 then
    status = status .. string.format("-%d", removed)
  end

  if status == "" then
    return component
  end
  return component .. " " .. status
end

---@return string
function M.dap_component()
  if not package.loaded["dap"] or require("dap").status() == "" then
    return nil
  end

  return string.format("%%#%s#%s  %s", M.get_or_create_hl "Special", icons.misc.bug, require("dap").status())
end

---@type table<string, string?>
local progress_status = {
  client = nil,
  kind = nil,
  title = nil,
}

vim.api.nvim_create_autocmd("LspProgress", {
  group = vim.api.nvim_create_augroup("statuslineprogress", { clear = true }),
  pattern = { "begin", "end" },
  callback = function(ev)
    if not ev.data then
      return
    end

    progress_status = {
      client = vim.lsp.get_client_by_id(ev.data.client_id).name,
      kind = ev.data.params.value.kind,
      title = ev.data.params.value.title,
    }

    if progress_status.kind == "end" then
      progress_status.title = nil
      vim.defer_fn(function()
        vim.cmd.redrawstatus()
      end, 3000)
    else
      vim.cmd.redrawstatus()
    end
  end,
})

---@return string
function M.lsp_progress_component()
  if not progress_status.client or not progress_status.title then
    return ""
  end

  if vim.startswith(vim.api.nvim_get_mode().mode, "i") then
    return ""
  end

  return table.concat({
      "%#StatuslineSpinner#󱥸 ",
      string.format("%%#StatuslineTitle#%s  ", progress_status.client),
      string.format("%%#StatuslineItalic#%s...", progress_status.title),
  })
end

---@return string
function M.encoding_component()
  local encoding = vim.opt.fileencoding:get()
  return encoding ~= "" and string.format("%%#StatuslineModeSeparatorOther# %s", encoding) or ""
end

---@return string
function M.position_component()
  local line = vim.fn.line(".")
  local line_count = vim.api.nvim_buf_line_count(0)
  local col = vim.fn.virtcol(".")

  return table.concat({
    "%#StatuslineItalic#l: ",
    string.format("%%#StatuslineTitle#%d", line),
    string.format("%%#StatuslineItalic#/%d c: %d", line_count, col),
  })
end

function M.render()
  ---@param components string[]
  ---@return string
  local function concat_components(components)
    return vim.iter(components):skip(1):fold(components[1], function(acc, component)
      return #component > 0 and string.format("%s    %s", acc, component) or acc
    end)
  end

  return table.concat({
    concat_components({
      M.mode_component(),
      M.git_component(),
      M.dap_component() or M.lsp_progress_component(),
    }),
    "%#StatusLine#%=",
    concat_components({
      vim.diagnostic.status(),
      M.filetype_component(),
      M.encoding_component(),
      M.position_component(),
    }),
  })
end

vim.o.statusline = "%!v:lua.require'statusline'.render()"

return M
