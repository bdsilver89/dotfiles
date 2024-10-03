local M = {}

local modes = {
  ["n"] = { "NORMAL", "Normal" },
  ["no"] = { "NORMAL (no)", "Normal" },
  ["nov"] = { "NORMAL (nov)", "Normal" },
  ["noV"] = { "NORMAL (noV)", "Normal" },
  ["noCTRL-V"] = { "NORMAL", "Normal" },
  ["niI"] = { "NORMAL i", "Normal" },
  ["niR"] = { "NORMAL r", "Normal" },
  ["niV"] = { "NORMAL v", "Normal" },
  ["nt"] = { "NTERMINAL", "NTerminal" },
  ["ntT"] = { "NTERMINAL (ntT)", "NTerminal" },

  ["v"] = { "VISUAL", "Visual" },
  ["vs"] = { "V-CHAR (Ctrl O)", "Visual" },
  ["V"] = { "V-LINE", "Visual" },
  ["Vs"] = { "V-LINE", "Visual" },
  [""] = { "V-BLOCK", "Visual" },

  ["i"] = { "INSERT", "Insert" },
  ["ic"] = { "INSERT (completion)", "Insert" },
  ["ix"] = { "INSERT completion", "Insert" },

  ["t"] = { "TERMINAL", "Terminal" },

  ["R"] = { "REPLACE", "Replace" },
  ["Rc"] = { "REPLACE (Rc)", "Replace" },
  ["Rx"] = { "REPLACEa (Rx)", "Replace" },
  ["Rv"] = { "V-REPLACE", "Replace" },
  ["Rvc"] = { "V-REPLACE (Rvc)", "Replace" },
  ["Rvx"] = { "V-REPLACE (Rvx)", "Replace" },

  ["s"] = { "SELECT", "Select" },
  ["S"] = { "S-LINE", "Select" },
  [""] = { "S-BLOCK", "Select" },
  ["c"] = { "COMMAND", "Command" },
  ["cv"] = { "COMMAND", "Command" },
  ["ce"] = { "COMMAND", "Command" },
  ["cr"] = { "COMMAND", "Command" },
  ["r"] = { "PROMPT", "Confirm" },
  ["rm"] = { "MORE", "Confirm" },
  ["r?"] = { "CONFIRM", "Confirm" },
  ["x"] = { "CONFIRM", "Confirm" },
  ["!"] = { "SHELL", "Terminal" },
}

local separators = {
  default = { left = "", right = "" },
  round = { left = "", right = "" },
  block = { left = "█", right = "█" },
  arrow = { left = "", right = "" },
}

local function stbufnr()
  return vim.api.nvim_win_get_buf(vim.g.statusline_winid or 0)
end

local function mode()
  if not vim.api.nvim_get_current_win() == stbufnr() then
    return ""
  end

  local m = vim.api.nvim_get_mode().mode

  return modes[m][1] .. " "
end

local function file()
  local icon = vim.g.enable_icons and "󰈚" or ""
  local path = vim.api.nvim_buf_get_name(stbufnr())
  local name = (path == "" and "Empty") or path:match("([^/\\]+)[/\\]*$")

  if name ~= "Empty" then
    local devicons_present, devicons = pcall(require, "nvim-web-devicons")

    if devicons_present then
      local ft_icon = devicons.get_icon(name)
      icon = (ft_icon ~= nil and ft_icon) or icon
    end
  end

  return " " .. icon .. "  " .. name .. " "
end

local function git()
  if not vim.b[stbufnr()].gitsigns_head or vim.b[stbufnr()].gitsigns_git_status then
    return ""
  end

  local git_status = vim.b[stbufnr()].gitsigns_status_dict

  local added_icon = vim.g.enable_icons and "  " or "+"
  local changed_icon = vim.g.enable_icons and "  " or "~"
  local removed_icon = vim.g.enable_icons and "  " or "-"
  local branch_icon = vim.g.enable_icons and " " or ""

  local added = (git_status.added and git_status.added ~= 0) and (added_icon .. git_status.added) or ""
  local changed = (git_status.changed and git_status.changed ~= 0) and (changed_icon .. git_status.changed) or ""
  local removed = (git_status.removed and git_status.removed ~= 0) and (removed_icon .. git_status.removed) or ""
  local branch_name = branch_icon .. git_status.head

  return " " .. branch_name .. added .. changed .. removed
end

local function lsp_msg()
  if vim.version().minor < 10 then
    return ""
  end

  local msg = vim.lsp.status()

  if #msg == 0 or vim.o.columns < 128 then
    return ""
  end

  local prefix = ""
  if vim.g.enable_icons then
    local spinners = { "", "󰪞", "󰪟", "󰪠", "󰪢", "󰪣", "󰪤", "󰪥" }
    local ms = vim.uv.hrtime() / 1e6
    local frame = math.floor(ms / 100) % #spinners

    prefix = spinners[frame + 1] .. " "
  end

  return prefix .. msg
end

local function diagnostics()
  if not rawget(vim, "lsp") then
    return ""
  end

  local err = #vim.diagnostic.get(stbufnr(), { severity = vim.diagnostic.severity.ERROR })
  local warn = #vim.diagnostic.get(stbufnr(), { severity = vim.diagnostic.severity.WARN })
  local hints = #vim.diagnostic.get(stbufnr(), { severity = vim.diagnostic.severity.HINT })
  local info = #vim.diagnostic.get(stbufnr(), { severity = vim.diagnostic.severity.INFO })

  local error_icon = vim.g.enable_icons and " " or ""
  local warn_icon = vim.g.enable_icons and " " or ""
  local hint_icon = vim.g.enable_icons and " " or ""
  local info_icon = vim.g.enable_icons and " " or ""

  local err_msg = (err and err > 0) and (error_icon .. err .. " ") or ""
  local warn_msg = (warn and warn > 0) and (warn_icon .. warn .. " ") or ""
  local hints_msg = (hints and hints > 0) and (hint_icon .. hints .. " ") or ""
  local info_msg = (info and info > 0) and (info_icon .. info .. " ") or ""

  return " " .. err_msg .. warn_msg .. hints_msg .. info_msg
end

local function lsp()
  local icon = vim.g.enable_icons and "   " or ""
  if rawget(vim, "lsp") and vim.version().minor >= 10 then
    for _, client in ipairs(vim.lsp.get_clients()) do
      if client.attached_buffers[stbufnr()] then
        return (vim.o.columns > 100 and icon .. "LSP ~ " .. client.name .. " ") or (icon .. "LSP ")
      end
    end
  end
  return ""
end

local function cwd()
  local name = vim.uv.cwd()
  local icon = vim.g.enable_icons and "󰉖 " or ""

  name = icon .. (name:match("([^/\\]+)[/\\]*$") or name) .. " "
  return (vim.o.columns > 85 and name) or ""
end

local function cursor()
  return "Ln %l, Col %c "
end

function M.eval()
  local components = {
    mode(),
    file(),
    git(),
    "%=",
    lsp_msg(),
    "%=",
    diagnostics(),
    lsp(),
    cwd(),
    cursor(),
  }

  return table.concat(components)
end

return M
