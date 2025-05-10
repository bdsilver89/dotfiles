local M = {}

local defaults = {
  debounce = 200,
  notify_jump = false,
  notify_end = true,
  foldopen = true,
  jumplist = true,
  modes = { "n", "i", "c" },
  filter = function(buf)
    return vim.g.cusorword ~= false and vim.b[buf].cusorword ~= false
  end,
}

M.enabled = false

local config = defaults
local ns = vim.api.nvim_create_namespace("vim_lsp_references")
local ns2 = vim.api.nvim_create_namespace("nvim.lsp.references")
local timer = (vim.uv or vim.loop).new_timer()

function M.enable()
  if M.enabled then
    return
  end
  M.enabled = true
  local group = vim.api.nvim_create_augroup("bdsilver89/cursorword", { clear = true })

  vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "ModeChanged" }, {
    group = group,
    callback = function()
      if not M.is_enabled({ modes = true }) then
        M.clear()
        return
      end
      if not ({ M.get() })[2] then
        M.update()
      end
    end,
  })
end

function M.disable()
  if not M.enabled then
    return
  end
  M.enabled = false
  vim.api.nvim_del_augroup_by_name("bdsilver89/cursorword")
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
    vim.api.nvim_buf_clear_namespace(buf, ns2, 0, -1)
  end
end

function M.clear()
  vim.lsp.buf.clear_references()
end

---@private
function M.update()
  local buf = vim.api.nvim_get_current_buf()
  timer:start(config.debounce, 0, function()
    vim.schedule(function()
      if vim.api.nvim_buf_is_valid(buf) then
        vim.api.nvim_buf_call(buf, function()
          if not M.is_enabled({ modes = true }) then
            return
          end
          vim.lsp.buf.document_highlight()
          M.clear()
        end)
      end
    end)
  end)
end

---@param opts? number|{buf?:number, modes:boolean}
function M.is_enabled(opts)
  if not M.enabled then
    return false
  end
  opts = type(opts) == "number" and { buf = opts } or opts or {}

  if opts.modes then
    local mode = vim.api.nvim_get_mode().mode:lower()
    mode = mode:gsub("\22", "v"):gsub("\19", "s")
    mode = mode:sub(1, 2) == "no" and "o" or mode
    mode = mode:sub(1, 1):match("[ncitsvo]") or "n"
    if not vim.tbl_contains(config.modes, mode) then
      return false
    end
  end

  local buf = opts.buf or vim.api.nvim_get_current_buf()
  if not config.filter(buf) then
    return false
  end
  local clients = vim.lsp.get_clients({ bufnr = buf })
  clients = vim.tbl_filter(function(client)
    return client.supports_method("textDocument/documentHighlight", { bufnr = buf })
  end, clients)
  return #clients > 0
end

---@private
function M.get()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local current, ret = nil, {}
  local extmarks = {}
  vim.list_extend(extmarks, vim.api.nvim_buf_get_extmarks(0, ns, 0, -1, { details = true }))
  vim.list_extend(extmarks, vim.api.nvim_buf_get_extmarks(0, ns2, 0, -1, { details = true }))
  for _, extmark in ipairs(extmarks) do
    local w = {
      from = { extmark[2] + 1, extmark[3] },
      to = { extmark[4].end_row + 1, extmark[4].end_col },
    }
    ret[#ret + 1] = w
    if cursor[1] >= w.from[1] and cursor[1] <= w.to[1] and cursor[2] >= w.from[2] and cursor[2] <= w.to[2] then
      current = #ret
    end
  end
  return ret, current
end

---@param count? number
---@param cycle? boolean
function M.jump(count, cycle)
  count = count or 1
  local words, idx = M.get()
  if not idx then
    return
  end
  idx = idx + count
  if cycle then
    idx = (idx - 1) % #words + 1
  end
  local target = words[idx]
  if target then
    if config.jumplist then
      vim.cmd.normal({ "m`", bang = true })
    end
    vim.api.nvim_win_set_cursor(0, target.from)
    if config.notify_jump then
      vim.notify(("Reference [%d/%d]"):format(idx, #words), vim.log.levels.INFO)
    end
    if config.foldopen then
      vim.cmd.normal({ "zv", bang = true })
    end
  elseif config.notify_end then
    vim.notify("No more references", vim.log.levels.WARN)
  end
end

return M
