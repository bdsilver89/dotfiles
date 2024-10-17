local M = {}

-- local modes = {
--   ["n"] = { "NORMAL", "Normal" },
--   ["no"] = { "NORMAL (no)", "Normal" },
--   ["nov"] = { "NORMAL (nov)", "Normal" },
--   ["noV"] = { "NORMAL (noV)", "Normal" },
--   ["noCTRL-V"] = { "NORMAL", "Normal" },
--   ["niI"] = { "NORMAL i", "Normal" },
--   ["niR"] = { "NORMAL r", "Normal" },
--   ["niV"] = { "NORMAL v", "Normal" },
--   ["nt"] = { "NTERMINAL", "NTerminal" },
--   ["ntT"] = { "NTERMINAL (ntT)", "NTerminal" },
--
--   ["v"] = { "VISUAL", "Visual" },
--   ["vs"] = { "V-CHAR (Ctrl O)", "Visual" },
--   ["V"] = { "V-LINE", "Visual" },
--   ["Vs"] = { "V-LINE", "Visual" },
--   [""] = { "V-BLOCK", "Visual" },
--
--   ["i"] = { "INSERT", "Insert" },
--   ["ic"] = { "INSERT (completion)", "Insert" },
--   ["ix"] = { "INSERT completion", "Insert" },
--
--   ["t"] = { "TERMINAL", "Terminal" },
--
--   ["R"] = { "REPLACE", "Replace" },
--   ["Rc"] = { "REPLACE (Rc)", "Replace" },
--   ["Rx"] = { "REPLACEa (Rx)", "Replace" },
--   ["Rv"] = { "V-REPLACE", "Replace" },
--   ["Rvc"] = { "V-REPLACE (Rvc)", "Replace" },
--   ["Rvx"] = { "V-REPLACE (Rvx)", "Replace" },
--
--   ["s"] = { "SELECT", "Select" },
--   ["S"] = { "S-LINE", "Select" },
--   [""] = { "S-BLOCK", "Select" },
--   ["c"] = { "COMMAND", "Command" },
--   ["cv"] = { "COMMAND", "Command" },
--   ["ce"] = { "COMMAND", "Command" },
--   ["cr"] = { "COMMAND", "Command" },
--   ["r"] = { "PROMPT", "Confirm" },
--   ["rm"] = { "MORE", "Confirm" },
--   ["r?"] = { "CONFIRM", "Confirm" },
--   ["x"] = { "CONFIRM", "Confirm" },
--   ["!"] = { "SHELL", "Terminal" },
-- }

local CTRL_S = vim.api.nvim_replace_termcodes("<c-s>", true, true, true)
local CTRL_V = vim.api.nvim_replace_termcodes("<c-v>", true, true, true)

local modes = setmetatable({
  ["n"] = { long = "NORMAL", short = "N", hl = "StatuslineModeNormal" },
  ["v"] = { long = "VISUAL", short = "V", hl = "StatuslineModeVisual" },
  ["V"] = { long = "V-LINE", short = "V-L", hl = "StatuslineModeVisual" },
  [CTRL_V] = { long = "V-BLOCK", short = "V-B", hl = "StatuslineModeVisual" },
  ["s"] = { long = "SELECT", short = "S", hl = "StatuslineModeVisual" },
  ["S"] = { long = "S-LINE", short = "S-L", hl = "StatuslineModeVisual" },
  [CTRL_S] = { long = "S-BLOCK", short = "S-B", hl = "StatuslineModeVisual" },
  ["i"] = { long = "INSERT", short = "I", hl = "StatuslineModeInsert" },
  ["R"] = { long = "REPLACE", short = "R", hl = "StatuslineModeReplace" },
  ["c"] = { long = "COMMAND", short = "C", hl = "StatuslineModeCommand" },
  ["r"] = { long = "PROMPT", short = "P", hl = "StatuslineModeOther" },
  ["!"] = { long = "SHELL", short = "Sh", hl = "StatuslineModeOther" },
  ["t"] = { long = "TERMINAL", short = "T", hl = "StatuslineModeOther" },
}, {
  __index = function()
    return { long = "UNKNOWN", short = "U", hl = "%#StatuslineModeOther#" }
  end,
})

local function stbufnr()
  return vim.api.nvim_win_get_buf(vim.g.statusline_winid or 0)
end

local function is_activewin()
  return vim.api.nvim_get_current_win() == vim.g.statusline_winid
end

local function mode()
  if not is_activewin() then
    return ""
  end

  local m = modes[vim.fn.mode()]

  return "%#" .. m.hl .. "# " .. m.long .. " "
end

local function file()
  local icon = "󰈚"
  local path = vim.api.nvim_buf_get_name(stbufnr())
  local name = (path == "" and "Empty ") or path:match("([^/\\]+)[/\\]*$")

  if name ~= "Empty " then
    local devicons_present, devicons = pcall(require, "nvim-web-devicons")
    if devicons_present then
      local ft_icon = devicons.get_icon(name)
      icon = (ft_icon ~= nil and ft_icon) or icon
    end
  end

  return "%#St_file# " .. icon .. " " .. name .. " "
end

local function git()
  if not vim.b[stbufnr()].gitsigns_head or vim.b[stbufnr()].gitsigns_git_status then
    return ""
  end

  local git_status = vim.b[stbufnr()].gitsigns_status_dict

  local added = (git_status.added and git_status.added ~= 0) and ("  " .. git_status.added) or ""
  local changed = (git_status.changed and git_status.changed ~= 0) and ("  " .. git_status.changed) or ""
  local removed = (git_status.removed and git_status.removed ~= 0) and ("  " .. git_status.removed) or ""
  local branch_name = " " .. git_status.head

  local msg = " " .. branch_name .. added .. changed .. removed

  return "%#StatuslineDevInfo#" .. msg
end

local function lsp_msg()
  local msg = vim.lsp.status()

  if #msg == 0 or vim.o.columns < 120 then
    return ""
  end

  local spinners = { "", "󰪞", "󰪟", "󰪠", "󰪢", "󰪣", "󰪤", "󰪥" }
  local ms = vim.uv.hrtime() / 1e6
  local frame = math.floor(ms / 100) % #spinners

  return "%#StatuslineDevInfo#" .. spinners[frame + 1] .. " " .. msg
end

local function diagnostics()
  if not rawget(vim, "lsp") then
    return ""
  end

  local err = #vim.diagnostic.get(stbufnr(), { severity = vim.diagnostic.severity.ERROR })
  local warn = #vim.diagnostic.get(stbufnr(), { severity = vim.diagnostic.severity.WARN })
  local hints = #vim.diagnostic.get(stbufnr(), { severity = vim.diagnostic.severity.HINT })
  local info = #vim.diagnostic.get(stbufnr(), { severity = vim.diagnostic.severity.INFO })

  -- TODO: highlights
  local err_str = (err and err > 0) and (" " .. err .. " ") or ""
  local warn_str = (warn and warn > 0) and (" " .. warn .. " ") or ""
  local hints_str = (hints and hints > 0) and ("󰛩 " .. hints .. " ") or ""
  local info_str = (info and info > 0) and ("󰋼 " .. info .. " ") or ""

  return " " .. err_str .. warn_str .. hints_str .. info_str
end

local function lsp()
  if rawget(vim, "lsp") then
    for _, client in ipairs(vim.lsp.get_clients()) do
      if client.attached_buffers[stbufnr()] then
        -- return "%#St_Lsp#" .. ((vim.o.columns > 100 and "   LSP ~ " .. client.name .. " ") or "   LSP ")
        return "%#StatuslineDevInfo#" .. ((vim.o.columns > 100 and " [" .. client.name .. "] ") or "[LSP]")
      end
    end
  end

  return ""
end

local function cwd()
  local name = vim.uv.cwd() or ""
  -- TODO: highlights
  name = "%#StatuslineFileinfo#" .. "󰉖 " .. (name:match("([^/\\]+)[/\\]*$") or name) .. " "
  return (vim.o.columns > 85 and name) or ""
end

local function cursor()
  local m = modes[vim.fn.mode()]
  return "%#" .. m.hl .. "# Ln %l, Col %c | %p %% "
end

function M.eval()
  local result = {
    mode(),
    file(),
    git(),
    "%<",
    "%=",
    lsp_msg(),
    "%=",
    diagnostics(),
    lsp(),
    cwd(),
    cursor(),
  }

  return table.concat(result)
end

function M.setup()
  vim.api.nvim_create_autocmd("LspProgress", {
    callback = function(args)
      if string.find(args.match, "end") then
        vim.cmd("redrawstatus")
      end
      vim.cmd("redrawstatus")
    end,
  })

  -- highlight groups
  vim.api.nvim_set_hl(0, "StatuslineModeNormal", { link = "Cursor" })
  vim.api.nvim_set_hl(0, "StatuslineModeInsert", { link = "DiffChange" })
  vim.api.nvim_set_hl(0, "StatuslineModeVisual", { link = "DiffAdd" })
  vim.api.nvim_set_hl(0, "StatuslineModeReplace", { link = "DiffDelete" })
  vim.api.nvim_set_hl(0, "StatuslineModeCommand", { link = "DiffText" })
  vim.api.nvim_set_hl(0, "StatuslineModeOther", { link = "IncSearch" })

  vim.api.nvim_set_hl(0, "StatuslineDevInfo", { link = "StatusLine" })
  vim.api.nvim_set_hl(0, "StatuslineFilename", { link = "StatusLineNC" })
  vim.api.nvim_set_hl(0, "StatuslineFileInfo", { link = "StatusLine" })
  vim.api.nvim_set_hl(0, "StatuslineInactive", { link = "StatusLineNC" })
end

return M
