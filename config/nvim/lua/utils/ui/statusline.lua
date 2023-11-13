local M = {}

M.filetypes = { "dashboard", "NvimTree", "^neo--tree$", "^neotoest--summary$", "^neo--tree--popup$", "toggleterm" }
M.buftypes = { "nofile", "prompt", "help", "quickfix" }
M.force_inactive_filetypes = { "aerial", "aerial-nav", "lazy", "undotree", "TelescopePrompt" }

M.mode_names = {
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
}

function M.vim_mode()
  -- force update when vim mode changes
  vim.api.nvim_create_autocmd("ModeChanged", {
    pattern = "*",
    callback = function()
      vim.cmd.redrawstatus()
    end,
  })

  return "%2(" .. M.mode_names[vim.fn.mode(1)] .. "%)"
end

function M.setup()
  local components = {
    -- M.vim_mode(),
  }

  return table.concat(components, "")
end

return M
