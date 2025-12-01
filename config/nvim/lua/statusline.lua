-- internal state for toggles
local state = {
  show_path = true,
  show_branch = true,
}

-- config for placeholders + highlighting
local config = {
  icons = {
    path = "",
    branch_hidden = "",
  },
  placeholder_hl = "StatusLineDim", -- a dim highlight group we define below
  modes = {
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
    ["ic"] = { "INSERT", "Insert" },
    ["ix"] = { "INSERT", "Insert" },

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
  },
}

-- helper to wrap text in a statusline highlight group
local function hl(group, text)
  return string.format("%%#%s#%s%%*", group, text)
end

-- set (or link) the dim highlight once
vim.api.nvim_set_hl(0, config.placeholder_hl, {}) -- create if missing
-- Link to Comment to keep it dim; adjust as you like
vim.api.nvim_set_hl(0, config.placeholder_hl, { link = "Comment" })

local function mode()
  local m = vim.api.nvim_get_mode().mode
  return "[" .. config.modes[m][1] .. "]"
end

local function filepath()
  local fpath = vim.fn.fnamemodify(vim.fn.expand "%", ":~:.:h")

  if fpath == "" or fpath == "." then
    return ""
  end

  if state.show_path then
    return string.format("%%<%s/", fpath)
  end

  return hl(config.placeholder_hl, config.icons.path .. "/")
end

local function git()
  local git_info = vim.b.gitsigns_status_dict
  if not git_info or git_info.head == "" then
    return ""
  end

  local head  = git_info.head
  local added   = git_info.added and (" +" .. git_info.added) or ""
  local changed = git_info.changed and (" ~" .. git_info.changed) or ""
  local removed = git_info.removed and (" -" .. git_info.removed) or ""
  if git_info.added == 0 then added = "" end
  if git_info.changed == 0 then changed = "" end
  if git_info.removed == 0 then removed = "" end

  if not state.show_branch then
    head = hl(config.placeholder_hl, config.icons.branch_hidden)
  end

  return table.concat({
    "[ ",
    head,
    added, changed, removed,
    "]",
  })
end

local function diagnostics()
  local status = vim.diagnostic.status()

  if not status or status == "" then
    return ""
  end

  return "[" .. status .. "]"
end


local lsp_msg = ""

local function lsp()
  return lsp_msg
end

vim.api.nvim_create_autocmd("LspProgress", {
  pattern = { "begin", "report", "end" },
  callback = function(ev)
    if not ev.data or not ev.data.params then
      return
    end

    local data = ev.data.params.value
    local loaded_count = data.message and string.match(data.message, "^(%d+/%d+)") or ""
    local str = (data.title or "") .. " " .. (loaded_count or "")
    lsp_msg = data.kind == "end" and "" or str
    vim.cmd.redrawstatus()
  end,
})


Statusline = {}

function Statusline.active()
  return table.concat {
    mode(),
    " ",
    "[", filepath(), "%t] ",
    git(),
    " ",
    diagnostics(),
    "%=",
    lsp(),
    " ",
    "%y [%l:%c %p%%]"
  }
end

function Statusline.inactive()
  return " %t"
end

function Statusline.toggle_path()
  state.show_path = not state.show_path
  vim.cmd("redrawstatus")
end

function Statusline.toggle_branch()
  state.show_branch = not state.show_branch
  vim.cmd("redrawstatus")
end

vim.keymap.set("n", "<leader>sp", function() Statusline.toggle_path() end, { desc = "Toggle statusline path" })
vim.keymap.set("n", "<leader>sb", function() Statusline.toggle_branch() end, { desc = "Toggle statusline git branch" })

local group = vim.api.nvim_create_augroup("Statusline", { clear = true })

vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
  group = group,
  desc = "Activate statusline on focus",
  callback = function()
  vim.opt_local.statusline = "%!v:lua.Statusline.active()"
  end,
})

vim.api.nvim_create_autocmd({ "WinLeave", "BufLeave" }, {
  group = group,
  desc = "Deactivate statusline when unfocused",
  callback = function()
  vim.opt_local.statusline = "%!v:lua.Statusline.inactive()"
  end,
})
