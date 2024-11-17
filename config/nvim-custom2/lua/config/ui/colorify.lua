local M = {}

local conf = {
  mode = "virtual", --  fg, bg, virtual
  virt_text = "󱓻 ",
  highlight = { hex = true, lspvars = true },
}

M.events = {}
local ns = 1

local function is_dark(hex)
  hex = hex:gsub("#", "")

  local r, g, b = tonumber(hex:sub(1, 2), 16), tonumber(hex:sub(3, 4), 16), tonumber(hex:sub(5, 6), 16)
  local brightness = (r * 299 + g * 587 + b * 114) / 1000

  return brightness < 128
end

local function add_hl(hex)
  local name = "hex_" .. hex:sub(2)

  local fg, bg = hex, hex

  if conf.mode == "bg" then
    fg = is_dark(hex) and "white" or "black"
  else
    bg = "none"
  end

  vim.api.nvim_set_hl(ns, name, { fg = fg, bg = bg })
  return name
end

local function not_colored(buf, linenr, col, hl_group, opts)
  local ms = vim.api.nvim_buf_get_extmarks(buf, ns, { linenr, col }, { linenr, opts.end_col }, { details = true })

  if #ms == 0 then
    return true
  end

  ms = ms[1]
  opts.id = ms[1]
  return hl_group ~= (ms[4].hl_group or ms[4].virt_text[1][2])
end

local function del_extmarks_on_textchange(buf)
  vim.b[buf].colorify_attached = true

  vim.api.nvim_buf_attach(buf, false, {
    -- s = start, e == end
    on_bytes = function(_, b, _, s_row, s_col, _, old_e_row, old_e_col, _, _, new_e_col, _)
      -- old_e_row = old deleted lines!
      -- new_e_col isnt 0 when cursor pos has changed
      if old_e_row == 0 and new_e_col == 0 and old_e_col == 0 then
        return
      end

      local row1, col1, row2, col2

      if old_e_row > 0 then
        row1, col1, row2, col2 = s_row, 0, s_row + old_e_row, 0
      else
        row1, col1, row2, col2 = s_row, s_col, s_row, s_col + old_e_col
      end

      local ms = vim.api.nvim_buf_get_extmarks(b, ns, { row1, col1 }, { row2, col2 }, { overlap = true })

      for _, mark in ipairs(ms) do
        vim.api.nvim_buf_del_extmark(b, ns, mark[1])
      end
    end,
    on_detach = function()
      vim.b[buf].colorify_attached = false
    end,
  })
end

function M.hex(buf, line, str)
  for col, hex in str:gmatch("()(#%x%x%x%x%x%x)") do
    col = col - 1
    local hl_group = add_hl(hex)
    local end_col = col + 7

    local opts = { end_col = end_col, hl_group = hl_group }

    if conf.mode == "virtual" then
      opts.hl_group = nil
      opts.virt_text_pos = "inline"
      opts.virt_text = { { conf.virt_text, hl_group } }
    end

    if not_colored(buf, line, col, hl_group, opts) then
      vim.api.nvim_buf_set_extmark(buf, ns, line, col, opts)
    end
  end
end

function M.lsp_var(buf, line, min, max)
  local param = { textDocument = vim.lsp.util.make_text_document_params(buf) }

  for _, client in pairs(vim.lsp.get_clients({ bufnr = buf })) do
    if client.server_capabilities.colorProvider then
      client.request("textDocument/documentColor", param, function(_, resp)
        if resp and line then
          resp = vim.tbl_filter(function(v)
            return v.range["start"].line == line
          end, resp)
        end

        if resp and min then
          resp = vim.tbl_filter(function(v)
            return v.range["start"].line >= min and v.range["end"].line <= max
          end, resp)
        end

        for _, match in ipairs(resp or {}) do
          local color = match.color
          local r, g, b, a = color.red, color.green, color.blue, color.alpha
          local hex = string.format("#%02x%02x%02x", r * a * 255, g * a * 255, b * a * 255)
          local hl_group = add_hl(hex)

          local range_start = match.range.start
          local range_end = match.range["end"]

          local opts = { end_col = range_end.character, hl_group = hl_group }

          if conf.mode == "virtual" then
            opts.hl_group = nil
            opts.virt_text_pos = "inline"
            opts.virt_text = { { conf.virt_text, hl_group } }
          end

          if not_colored(buf, range_start.line, range_start.character, hl_group, opts) then
            vim.api.nvim_buf_set_extmark(buf, ns, range_start.line, range_start.character, opts)
          end
        end
      end, buf)
    end
  end
end

function M.attach(buf, event)
  local winid = vim.fn.bufwinid(buf)
  local min = vim.fn.line("w0", winid) - 1
  local max = vim.fn.line("w$", winid) + 1

  if event == "TextChangedI" then
    local cur_linenr = vim.fn.line(".", winid) - 1
    M.hex(buf, cur_linenr, vim.api.nvim_get_current_line())
    M.lsp_var(buf, cur_linenr)
    return
  end

  local lines = vim.api.nvim_buf_get_lines(buf, min, max, false)
  for i, str in ipairs(lines) do
    M.hex(buf, min + i - 1, str)
  end

  M.lsp_var(buf, nil, min, max)

  if event == "BufEnter" and not vim.b[buf].colorify_attached then
    del_extmarks_on_textchange(buf)
  end
end

function M.setup()
  ns = vim.api.nvim_create_namespace("colorify")
  vim.api.nvim_set_hl_ns(ns)

  vim.api.nvim_create_autocmd(
    { "TextChanged", "TextChangedI", "TextChangedP", "VimResized", "LspAttach", "WinScrolled", "BufEnter" },
    {
      desc = "Colorify file",
      callback = function(event)
        if vim.bo[event.buf].bl then
          M.attach(event.buf, event.event)
        end
      end,
    }
  )
end

return M
