local icons = require("icons")

local M = {}

---@type table<string, boolean>
local statusline_hls = {}

function M.get_or_create_hl(hl)
  local hl_name = "Statusline" .. hl
  if not statusline_hls[hl] then
    local bg_hl = vim.api.nvim_get_hl(0, { name = "Statusline" })
    local fg_hl = vim.api.nvim_get_hl(0, { name = hl })
    vim.api.nvim_set_hl(0, hl_name, { bg = ('#%06x'):format(bg_hl.bg), fg = ('#%06x'):format(fg_hl.fg) })
    statusline_hls[hl] = true
  end
  return hl_name
end

function M.mode_component()
  local mode_to_str = {
    ['n'] = 'NORMAL',
    ['no'] = 'OP-PENDING',
    ['nov'] = 'OP-PENDING',
    ['noV'] = 'OP-PENDING',
    ['no\22'] = 'OP-PENDING',
    ['niI'] = 'NORMAL',
    ['niR'] = 'NORMAL',
    ['niV'] = 'NORMAL',
    ['nt'] = 'NORMAL',
    ['ntT'] = 'NORMAL',
    ['v'] = 'VISUAL',
    ['vs'] = 'VISUAL',
    ['V'] = 'VISUAL',
    ['Vs'] = 'VISUAL',
    ['\22'] = 'VISUAL',
    ['\22s'] = 'VISUAL',
    ['s'] = 'SELECT',
    ['S'] = 'SELECT',
    ['\19'] = 'SELECT',
    ['i'] = 'INSERT',
    ['ic'] = 'INSERT',
    ['ix'] = 'INSERT',
    ['R'] = 'REPLACE',
    ['Rc'] = 'REPLACE',
    ['Rx'] = 'REPLACE',
    ['Rv'] = 'VIRT REPLACE',
    ['Rvc'] = 'VIRT REPLACE',
    ['Rvx'] = 'VIRT REPLACE',
    ['c'] = 'COMMAND',
    ['cv'] = 'VIM EX',
    ['ce'] = 'EX',
    ['r'] = 'PROMPT',
    ['rm'] = 'MORE',
    ['r?'] = 'CONFIRM',
    ['!'] = 'SHELL',
    ['t'] = 'TERMINAL',
  }

  local mode = mode_to_str[vim.api.nvim_get_mode().mode] or "UNKNOWN"

  local hl = "Other"
  if mode:find("NORMAL") then
    hl = "Normal"
  elseif mode:find 'PENDING' then
    hl = 'Pending'
  elseif mode:find 'VISUAL' then
    hl = 'Visual'
  elseif mode:find 'INSERT' or mode:find 'SELECT' then
    hl = 'Insert'
  elseif mode:find 'COMMAND' or mode:find 'TERMINAL' or mode:find 'EX' then
    hl = 'Command'
  end

  return table.concat({
    string.format('%%#StatuslineModeSeparator%s#', hl),
    string.format('%%#StatuslineMode%s#%s', hl, mode),
    string.format('%%#StatuslineModeSeparator%s#', hl),
  })
end

function M.git_component()
  local head = vim.b.gitsigns_head
  if not head or head == "" then
    return ""
  end

  local component = string.format(' %s', head)

  local status = vim.b.gitsigns_status
  if status and status ~= "" then
    component = component .. " " .. status
  end

  return component
end

function M.dap_component()
  if not package.loaded["dap"] or require("dap").status() == "" then
    return nil
  end

  return string.format('%%#%s#%s  %s', M.get_or_create_hl 'Special', icons.misc.bug, require('dap').status())
end

local progress_status = {
  client = nil,
  kind = nil,
  title = nil,
}

vim.api.nvim_create_autocmd("LspProgress", {
  group = vim.api.nvim_create_augroup("config_statuslinelsp", { clear = true }),
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

function M.lsp_progress_component()
  if not progress_status.client or not progress_status.title then
    return ""
  end

  if vim.startswith(vim.api.nvim_get_mode().mode, "i") then
    return ""
  end

  return table.concat({
    '%#StatuslineSpinner#󱥸 ',
    string.format('%%#StatuslineTitle#%s  ', progress_status.client),
    string.format('%%#StatuslineItalic#%s...', progress_status.title),
  })
end

function M.diagnostic_component()
  return vim.diagnostic.status()
end


function M.filetype_component()
  return ""
end

function M.encoding_component()
  local encoding = vim.opt.fileencoding:get()
  return encoding ~= '' and string.format('%%#StatuslineModeSeparatorOther# %s', encoding) or ''
end

function M.position_component()
  local line = vim.fn.line(".")
  local line_count = vim.api.nvim_buf_line_count(0)
  local col = vim.fn.virtcol(".")

  return table.concat({
    '%#StatuslineItalic#l: ',
    string.format('%%#StatuslineTitle#%d', line),
    string.format('%%#StatuslineItalic#/%d c: %d', line_count, col),
  })
end

function M.render()
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
      M.diagnostic_component(),
      M.filetype_component(),
      M.encoding_component(),
      M.position_component(),
    }),
  }, " ")
end

vim.o.statusline = "%!v:lua.require'statusline'.render()"

return M
