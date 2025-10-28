local M = {}

local utils = require("utils.statusline.utils")

local sep_style = "none"
local sep_icons = utils.separators
local separators = sep_icons[sep_style]

local sep_l = separators["left"]
local sep_r = separators["right"]

M["%="] = "%="

function M.mode()
  if not utils.is_activewin() then
    return ""
  end

  local modes = utils.modes

  local m = vim.api.nvim_get_mode().mode

  local current_mode = "%#St_" .. modes[m][2] .. "Mode#  " .. modes[m][1]
  local mode_sep1 = "%#St_" .. modes[m][2] .. "ModeSep#" .. sep_r
  return current_mode .. mode_sep1 .. "%#ST_EmptySpace#" .. sep_r
end

function M.file()
  local icon = "󰈚"
  local path = vim.api.nvim_buf_get_name(utils.stbufnr())
  local name = (path == "" and "Empty") or path:match "([^/\\]+)[/\\]*$"

  if name ~= "Empty" then
    local devicons_present, devicons = pcall(require, "nvim-web-devicons")

    if devicons_present then
      local ft_icon = devicons.get_icon(name)
      icon = (ft_icon ~= nil and ft_icon) or icon
    end
  end

  name = " " .. name .. (sep_style == "default" and " " or "")
  return "%#St_file# " .. icon .. name .. "%#St_file_sep#" .. sep_r
end

function M.git()
  if not vim.b[utils.stbufnr()].gitsigns_head or vim.b[utils.stbufnr()].gitsigns_git_status then
    return ""
  end

  local git_status = vim.b[utils.stbufnr()].gitsigns_status_dict

  local added = (git_status.added and git_status.added ~= 0) and ("  " .. git_status.added) or ""
  local changed = (git_status.changed and git_status.changed ~= 0) and ("  " .. git_status.changed) or ""
  local removed = (git_status.removed and git_status.removed ~= 0) and ("  " .. git_status.removed) or ""
  local branch_name = " " .. git_status.head

  return "%#St_gitIcons# " .. branch_name .. added .. changed .. removed
end

function M.lsp_msg()
  local msg = vim.o.columns < 120 and "" or utils.state.lsp_msg
  return "%#St_LspMsg#" .. msg
end

function M.diagnostics()
  if not rawget(vim, "lsp") then
    return ""
  end

  local err = #vim.diagnostic.get(utils.stbufnr(), { severity = vim.diagnostic.severity.ERROR })
  local warn = #vim.diagnostic.get(utils.stbufnr(), { severity = vim.diagnostic.severity.WARN })
  local hints = #vim.diagnostic.get(utils.stbufnr(), { severity = vim.diagnostic.severity.HINT })
  local info = #vim.diagnostic.get(utils.stbufnr(), { severity = vim.diagnostic.severity.INFO })

  err = (err and err > 0) and ("%#DiagnosticSignError#" .. " " .. err .. " ") or ""
  warn = (warn and warn > 0) and ("%#DiagnosticSignWarn#" .. " " .. warn .. " ") or ""
  hints = (hints and hints > 0) and ("%#DiagnosticSignHint#" .. "󰛩 " .. hints .. " ") or ""
  info = (info and info > 0) and ("%#DiagnosticSignInfo#" .. "󰋼 " .. info .. " ") or ""

  return " " .. err .. warn .. hints .. info
end

function M.clients()
  local clients = {}

  for _, client in pairs(vim.lsp.get_clients({ bufnr = utils.stbufnr() })) do
    table.insert(clients, client.name)
  end

  -- local lint_ok, lint = pcall(require, "lint")
  -- if lint_ok then
  -- end

  local conform_ok, conform = pcall(require, "conform")
  if conform_ok then
    for _, formatter in pairs(conform.list_formatters(utils.stbufnr())) do
      if not vim.tbl_contains(clients, formatter.name) then
        table.insert(clients.formatter.name)
      end
    end
  end

  if #clients == 0 then
    return ""
  else
    return (vim.o.columns > 100 and (" %#St_gitIcons#" .. table.concat(clients, ", ") .. " ")) or "  LSP "
  end
end

function M.cursor()
  return "%#St_pos_sep#" .. sep_l .. "%#St_pos_icon# %#St_pos_text# %l:%v %p %%"
end

function M.cwd()
  local icon = "%#St_cwd_icon#" .. "󰉋 "
  local name = vim.uv.cwd()
  name = "%#St_cwd_text#" .. " " .. (name:match "([^/\\]+)[/\\]*$" or name) .. " "
  return (vim.o.columns > 85 and ("%#St_cwd_sep#" .. sep_l .. icon .. name)) or ""
end

return M
