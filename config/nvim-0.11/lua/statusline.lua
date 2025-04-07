local icons = require("icons")

local M = {}

local statusline_hls = {}

function M.get_or_create_hl(hl)
  local hl_name = "Statusline" .. hl

  if not statusline_hls[hl] then
    local bg_hl = vim.api.nvim_get_hl(0, { name = "StatusLine" })
    local fg_hl = vim.api.nvim_get_hl(0, { name = hl })
    vim.api.nvim_set_hl(0, hl_name, { bg = ("#%06x"):format(bg_hl.bg), fg = ("#%06x"):format(fg_hl.fg) })
    statusline_hls[hl] = true
  end

  return hl_name
end

function M.mode_component()
  -- Note that: \19 = ^S and \22 = ^V.
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
  elseif mode:find("COMMAND") or mode:find("TERMINAL") or mode:find("EX") then
    hl = "Command"
  end

  return table.concat({
    string.format("%%#StatuslineModeSeparator%s#", hl),
    string.format("%%#StatuslineMode%s#%s", hl, mode),
    string.format("%%#StatuslineModeSeparator%s#", hl),
  })
end

function M.git_component()
  local head = vim.b.gitsigns_head
  local status_dict = vim.b.gitsigns_status_dict
  if not head or head == "" or not status_dict then
    return ""
  end
  local status = ""
  local added = status_dict.added or 0
  local removed = status_dict.removed or 0
  local changed = status_dict.changed or 0

  local has_changes = added ~= 0 or removed ~= 0 or changed ~= 0

  return table.concat({
    string.format(" %s", head),
    has_changes and table.concat({
      "%#StatusLine#(",
      added > 0 and string.format("%%#StatuslineGitAdded#+%d", added) or "",
      removed > 0 and string.format("%%#StatuslineGitRemoved#-%d", removed) or "",
      changed > 0 and string.format("%%#StatuslineGitChanged#~%d", changed) or "",
      "%#StatusLine#)",
    }) or "",
  })
end

function M.dap_component()
  if not package.loaded["dap"] or require("dap").status() == "" then
    return nil
  end

  return string.format("%%#%s#%s  %s", M.get_or_create_hl("DapUIRestart"), icons.misc.bug, require("dap").status())
end

-- local progress_status = {
--   client = nil,
--   kind = nil,
--   title = nil,
-- }
--
-- vim.api.nvim_create_autocmd("LspProgress", {
--   desc = "Update LSP progress in statusline",
--   group = vim.api.nvim_create_augroup("bdsilver89/statusline_lsp_progress", { clear = true }),
--   pattern = { "begin", "end" },
--   callback = function(args)
--     if not args.data then
--       return
--     end
--
--     progress_status = {
--       client = vim.lsp.get_client_by_id(args.data.client_id).name,
--       kind = args.data.params.value.kind,
--       title = args.data.params.value.title,
--     }
--
--     if progress_status.kind == "end" then
--       progress_status.title = nil
--       vim.defer_fn(function()
--         vim.cmd.redrawstatus()
--       end, 3000)
--     else
--       vim.cmd.redrawstatus()
--     end
--   end,
-- })
--
-- function M.lsp_progress_component()
--   if not progress_status.client or not progress_status.title then
--     return ""
--   end
--
--   if vim.startswith(vim.api.nvim_get_mode().mode, "i") then
--     return ""
--   end
--
--   return table.concat({
--     "%#StatuslineSpinner#󱥸 ",
--     string.format("%%#StatuslineTitle#%s  ", progress_status.client),
--     string.format("%%#StatuslineItalic#%s...", progress_status.title),
--   })
-- end

local lsp_state = { msg = "", idx = 0 }
local spinners = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }

vim.api.nvim_create_autocmd("LspProgress", {
  pattern = { "begin", "report", "end" },
  callback = function(args)
    if not args.data or not args.data.params then
      return
    end

    local data = args.data.params.value
    local progress = ""

    -- spinner
    local idx = lsp_state.idx
    idx = (idx % #spinners) + 1
    lsp_state.idx = idx
    progress = spinners[idx] .. " "

    -- percentage
    if data.percentage then
      progress = progress .. data.percentage .. "%% "
    end

    local loaded_count = data.message and string.match(data.message, "^(%d+/%d+)") or ""
    local str = progress .. (data.title or "") .. " " .. (loaded_count or "")
    lsp_state.msg = data.kind == "end" and "" or str
    vim.cmd.redrawstatus()
  end,
})

function M.lsp_progress_component()
  return lsp_state.msg
end

local last_diagnostic_component = ""

function M.diagnostics_component()
  if vim.startswith(vim.api.nvim_get_mode().mode, "i") then
    return last_diagnostic_component
  end

  local counts = vim.iter(vim.diagnostic.get(0)):fold({
    ERROR = 0,
    WARN = 0,
    HINT = 0,
    INFO = 0,
  }, function(acc, diagnostic)
    local severity = vim.diagnostic.severity[diagnostic.severity]
    acc[severity] = acc[severity] + 1
    return acc
  end)

  local parts = vim
    .iter(counts)
    :map(function(severity, count)
      if count == 0 then
        return nil
      end

      local hl = "Diagnostic" .. severity:sub(1, 1) .. severity:sub(2):lower()
      return string.format("%%#%s#%s %d", M.get_or_create_hl(hl), icons.diagnostics[severity], count)
    end)
    :totable()

  return table.concat(parts, " ")
end

function M.filetype_component()
  local filetype = vim.bo.filetype
  if filetype == "" then
    filetype = "[No Name]"
  end

  local buf_name = vim.api.nvim_buf_get_name(0)
  local name, ext = vim.fn.fnamemodify(buf_name, ":t"), vim.fn.fnamemodify(buf_name, ":e")

  local devicons = require("nvim-web-devicons")
  local icon, icon_hl = devicons.get_icon(name, ext)
  if not icon then
    icon, icon_hl = devicons.get_icon_by_filetype(filetype, { default = true })
  end

  return string.format("%%#%s#%s %%#StatuslineTitle#%s", icon_hl, icon, filetype)
end

function M.encoding_component()
  local encoding = vim.opt.fileencoding:get()
  return encoding ~= "" and string.format("%%#StatuslineModeSeparatorOther# %s", encoding) or ""
end

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
  local concat_components = function(components)
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
      M.diagnostics_component(),
      M.filetype_component(),
      M.encoding_component(),
      M.position_component(),
    }),
  }, " ")
end

-- setup highlight groups for statusline
-- local function create_hl()
--   local get_highlight = function(name)
--     return vim.api.nvim_get_hl(0, { name = name, link = false, create = false })
--   end
--
--   local red = get_highlight("DiagnosticError").fg
--   local green = get_highlight("String").fg
--   local cyan = get_highlight("Special").fg
--   local orange = get_highlight("Constant").fg
--   local purple = get_highlight("Statement").fg
--
--   local statusline = get_highlight("StatusLine")
--
--   local groups = {
--     StatuslineModeNormal = {}, -- { bg = red },
--     StatuslineModePending = {}, -- { bg = purple },
--     StatuslineModeVisual = {}, -- { bg = cyan },
--     StatuslineModeInsert = {}, --{ bg = green },
--     StatuslineModeCommand = {}, --{ bg = orange },
--     StatuslineModeOther = {}, --{ bg = purple },
--     StatuslineModeSeparatorNormal = {}, --{ fg = red },
--     StatuslineModeSeparatorPending = {}, --{ fg = purple },
--     StatuslineModeSeparatorVisual = {}, --{ fg = cyan },
--     StatuslineModeSeparatorInsert = {}, --{ fg = green },
--     StatuslineModeSepartorCommand = {}, --{ fg = orange },
--     StatuslineModeSeparatorOther = {}, -- { fg = purple },
--     StatuslineGitAdded = { fg = get_highlight("GitSignsAdd").fg, bg = statusline.bg },
--     StatuslineGitRemoved = { fg = get_highlight("GitSignsDelete").fg, bg = statusline.bg },
--     StatuslineGitChanged = { fg = get_highlight("GitSignsChange").fg, bg = statusline.bg },
--     StatuslineItalic = { fg = statusline.fg, bg = statusline.bg, italic = true },
--     StatuslineSpinner = { fg = green, bg = statusline.bg },
--     StatuslineTitle = { fg = statusline.fg, bg = statusline.bg, bold = true },
--   }
--
--   for group, opts in pairs(groups) do
--     vim.api.nvim_set_hl(0, group, opts)
--   end
-- end
--
-- vim.api.nvim_create_autocmd("ColorScheme", {
--   callback = create_hl,
-- })

vim.o.statusline = "%!v:lua.require'statusline'.render()"

return M
