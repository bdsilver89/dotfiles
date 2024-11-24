local M = {}

local defaults = {
  width = 60,
  row = nil,
  col = nil,
  pane_gap = 4,
  preset = {
    keys = {},
    header = [[
███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝]],
  },
  formats = {},
  sections = {},
}

local style = {
  zindex = 10,
  height = 0.6,
  width = 0.6,
  bo = {
    bufhidden = "wipe",
    buftype = "nofile",
    swapfile = false,
    undofile = false,
  },
  wo = {
    colorcolumn = "",
    cursorcolumn = false,
    cursorline = false,
    list = false,
    number = false,
    relativenumber = false,
    sidescrolloff = 0,
    signcolumn = "no",
    spell = false,
    statuscolumn = "",
    statusline = "",
    winbar = "",
    winhighlight = "Normal:DashboardNormal,NormalFloat:DashboardNormal",
    wrap = false,
  },
}

M.ns = vim.api.nvim_create_namespace("config_dashboard")

local D = {}

function D:init() end

function D:size()
  return {
    width = vim.api.nvim_win_get_width(self.win),
    height = vim.api.nvim_win_get_height(self.win) + (vim.o.laststatus >= 2 and 1 or 0),
  }
end

function D:is_float()
  return vim.api.nvim_win_get_config(self.win).relative ~= ""
end

function D:action(action)
  if self:is_float() then
    vim.api.nvim_win_close(self.win, true)
    self.win = nil
  end
  vim.schedule(function()
    if type(action) == "string" then
      if action:find("^:") then
        return vim.cmd(action.sub(2))
      else
        local keys = vim.api.nvim_replace_termcodes(action, true, true, true)
        return vim.api.nvim_feedkeys(keys, "tm", true)
      end
    end
    action(self)
  end)
end

function D:format_field(item, field, width) end

function D:align() end

function D:text() end

function D:block() end

function D:format() end

function D:enabled() end

function D:padding() end

function D:fire() end

function D:on() end

function D:find() end

function D:layout() end

function D:render() end

function D:keys() end

function D:update() end

M.sections = {}

function M.open(opts)
  local self = setmetatable({}, { __index = D })
  self.opts = vim.tbl_deep_extend("force", defaults, opts or {})
  self.buf = self.opts.buf or vim.api.nvim_create_buf(false, true)
  self.win = self.opts.win or require("config.utils.win")({ buf = self.buf, enter = true }).win
  self:init()
  self:update()
  return self
end

local function setup_highlights()
  local set_default_hl = function(name, data)
    data.default = true
    vim.api.nvim_set_hl(0, name, data)
  end

  set_default_hl("DashboardDesc", { link = "Special" })
  set_default_hl("DashboardFile", { link = "Special" })
  set_default_hl("DashboardDir", { link = "NonText" })
  set_default_hl("DashboardFooter", { link = "Title" })
  set_default_hl("DashboardHeader", { link = "Title" })
  set_default_hl("DashboardIcon", { link = "Special" })
  set_default_hl("DashboardKey", { link = "Number" })
  set_default_hl("DashboardNormal", { link = "Normal" })
  set_default_hl("DashboardTerminal", { link = "DashboardNormal" })
  set_default_hl("DashboardSpecial", { link = "Special" })
  set_default_hl("DashboardTitle", { link = "Title" })
end

function M.setup()
  setup_highlights()

  local buf = 1

  if vim.fn.argc() > 0 then
    return
  end

  local wins = vim.tbl_filter(function(win)
    return vim.api.nvim_win_get_config(win).relative == ""
  end, vim.api.nvim_list_wins())
  if #wins ~= 1 then
    return
  elseif vim.api.nvim_win_get_buf(wins[1]) ~= buf then
    return
  end

  if vim.bo[buf].modified then
    return
  end

  local uis = vim.api.nvim_list_uis()

  if #uis == 0 then
    return
  end

  if uis[1].stdin_tty == false then
    return
  end

  if vim.api.nvim_buf_line_count(buf) > 1 or #(vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] or "") > 0 then
    return
  end
  M.open({ buf = buf, win = wins[1] })
end

return M
