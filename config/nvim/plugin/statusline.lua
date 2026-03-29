local M = {}

local mode_map = {
  ["n"] = { "NORMAL", "ModeNormal" },
  ["no"] = { "OP-PENDING", "ModeNormal" },
  ["nov"] = { "OP-PENDING", "ModeNormal" },
  ["noV"] = { "OP-PENDING", "ModeNormal" },
  ["no\22"] = { "OP-PENDING", "ModeNormal" },
  ["niI"] = { "NORMAL", "ModeNormal" },
  ["niR"] = { "NORMAL", "ModeNormal" },
  ["niV"] = { "NORMAL", "ModeNormal" },
  ["nt"] = { "NORMAL", "ModeNormal" },
  ["ntT"] = { "NORMAL", "ModeNormal" },
  ["v"] = { "VISUAL", "ModeVisual" },
  ["vs"] = { "VISUAL", "ModeVisual" },
  ["V"] = { "VISUAL LINE", "ModeVisual" },
  ["Vs"] = { "VISUAL LINE", "ModeVisual" },
  ["\22"] = { "VISUAL BLOCK", "ModeVisual" },
  ["\22s"] = { "VISUAL BLOCK", "ModeVisual" },
  ["s"] = { "SELECT", "ModeVisual" },
  ["S"] = { "SELECT LINE", "ModeVisual" },
  ["\19"] = { "SELECT BLOCK", "ModeVisual" },
  ["i"] = { "INSERT", "ModeInsert" },
  ["ic"] = { "INSERT", "ModeInsert" },
  ["ix"] = { "INSERT", "ModeInsert" },
  ["R"] = { "REPLACE", "ModeReplace" },
  ["Rc"] = { "REPLACE", "ModeReplace" },
  ["Rx"] = { "REPLACE", "ModeReplace" },
  ["Rv"] = { "VIRTUAL REPLACE", "ModeReplace" },
  ["Rvc"] = { "VIRTUAL REPLACE", "ModeReplace" },
  ["Rvx"] = { "VIRTUAL REPLACE", "ModeReplace" },
  ["c"] = { "COMMAND", "ModeCommand" },
  ["cv"] = { "EX", "ModeCommand" },
  ["ce"] = { "EX", "ModeCommand" },
  ["r"] = { "HIT-ENTER", "ModeNormal" },
  ["rm"] = { "MORE", "ModeNormal" },
  ["r?"] = { "CONFIRM", "ModeNormal" },
  ["!"] = { "SHELL", "ModeCommand" },
  ["t"] = { "TERMINAL", "ModeCommand" },
}

local function setup_highlights()
  local function fg(name)
    local h = vim.api.nvim_get_hl(0, { name = name, link = false })
    return h.fg
  end

  local dark = vim.api.nvim_get_hl(0, { name = "Normal", link = false }).bg or 0x232634

  -- mode highlights: bold inverted using semantic source colors
  vim.api.nvim_set_hl(0, "ModeNormal", { fg = dark, bg = fg("Function"), bold = true })
  vim.api.nvim_set_hl(0, "ModeInsert", { fg = dark, bg = fg("String"), bold = true })
  vim.api.nvim_set_hl(0, "ModeVisual", { fg = dark, bg = fg("Keyword"), bold = true })
  vim.api.nvim_set_hl(0, "ModeReplace", { fg = dark, bg = fg("DiagnosticError"), bold = true })
  vim.api.nvim_set_hl(0, "ModeCommand", { fg = dark, bg = fg("Constant"), bold = true })
end

local function mode()
  local m = vim.api.nvim_get_mode().mode
  local info = mode_map[m] or { m, "ModeNormal" }
  return "%#" .. info[2] .. "# " .. info[1] .. " %#StatusLine#"
end

local function git_branch()
  local head = vim.b.gitsigns_head
  if not head or head == "" then return "" end
  return "%#Keyword#  " .. head .. " "
end

local function git_diff()
  local status = vim.b.gitsigns_status_dict
  if not status then return "" end
  local parts = {}
  if (status.added or 0) > 0 then parts[#parts + 1] = "%#GitSignsAdd#+" .. status.added end
  if (status.changed or 0) > 0 then parts[#parts + 1] = "%#GitSignsChange#~" .. status.changed end
  if (status.removed or 0) > 0 then parts[#parts + 1] = "%#GitSignsDelete#-" .. status.removed end
  if #parts == 0 then return "" end
  return " " .. table.concat(parts, " ") .. " "
end

local function diagnostics()
  local buf = vim.api.nvim_get_current_buf()
  local counts = {}
  for _, d in ipairs(vim.diagnostic.get(buf)) do
    counts[d.severity] = (counts[d.severity] or 0) + 1
  end
  local parts = {}
  local s = vim.diagnostic.severity
  local icons = vim.diagnostic.config().signs.text
  if (counts[s.ERROR] or 0) > 0 then parts[#parts + 1] = "%#DiagnosticError#" .. icons[s.ERROR] .. counts[s.ERROR] end
  if (counts[s.WARN] or 0) > 0 then parts[#parts + 1] = "%#DiagnosticWarn#" .. icons[s.WARN] .. counts[s.WARN] end
  if (counts[s.INFO] or 0) > 0 then parts[#parts + 1] = "%#DiagnosticInfo#" .. icons[s.INFO] .. counts[s.INFO] end
  if (counts[s.HINT] or 0) > 0 then parts[#parts + 1] = "%#DiagnosticHint#" .. icons[s.HINT] .. counts[s.HINT] end
  if #parts == 0 then return "" end
  return " " .. table.concat(parts, " ") .. " "
end

local function lsp_name()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  if #clients == 0 then return "" end
  return "%#Comment# " .. clients[1].name .. " "
end

local lsp_progress = {}

vim.api.nvim_create_autocmd("LspProgress", {
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if not client then return end
    local val = ev.data.params.value
    local key = client.id .. ":" .. tostring(ev.data.params.token)
    if val.kind == "end" then
      lsp_progress[key] = nil
    else
      local msg = client.name
      if val.percentage then msg = msg .. " " .. val.percentage .. "%%" end
      if val.title then msg = msg .. ": " .. val.title end
      if val.message then msg = msg .. " " .. val.message end
      lsp_progress[key] = msg
    end
    vim.cmd.redrawstatus()
  end,
})

local function progress()
  local key = next(lsp_progress)
  if not key then return "" end
  return "%#DiagnosticInfo# " .. lsp_progress[key] .. " "
end

local function filetype()
  local ft = vim.bo.filetype
  if ft == "" then return "" end
  return "%#Type# " .. ft .. " "
end

function M.render()
  return table.concat({
    mode(),
    git_branch(),
    git_diff(),
    "%#StatusLine# %f %m%r",
    "%=",
    progress(),
    diagnostics(),
    lsp_name(),
    filetype(),
    "%#StatusLine# %l:%c %p%% ",
  })
end

setup_highlights()

vim.api.nvim_create_autocmd("ColorScheme", {
  callback = setup_highlights,
})

_G.Statusline = M
vim.opt.statusline = "%!v:lua.Statusline.render()"
