local M = {}

local terms = {}
local order = {}
local last = nil

local function alive(t)
  return t ~= nil and t.buf ~= nil and vim.api.nvim_buf_is_valid(t.buf)
end

local function visible(t)
  return t ~= nil and t.win ~= nil and vim.api.nvim_win_is_valid(t.win)
end

-- Numbered shells only; dedicated tool terminals stay out of the bar.
local function shells()
  local out = {}
  for _, key in ipairs(order) do
    local t = terms[key]
    if alive(t) and not t.tui then
      out[#out + 1] = t
    end
  end
  return out
end

local function redraw()
  local list = shells()
  local parts = {}
  for _, t in ipairs(list) do
    local hl = t.key == last and "%#TabLineSel#" or "%#TabLine#"
    parts[#parts + 1] = ("%s %s "):format(hl, t.label)
  end
  local bar = table.concat(parts) .. "%#TabLineFill#"

  for _, t in ipairs(list) do
    if visible(t) then
      vim.wo[t.win].winbar = bar
    end
  end
end

local function forget(t)
  terms[t.key] = nil
  for i, key in ipairs(order) do
    if key == t.key then
      table.remove(order, i)
      break
    end
  end
  if last == t.key then
    last = nil
  end
end

local function open_win(t)
  if t.direction == "float" then
    local width = math.floor(vim.o.columns * 0.85)
    local height = math.floor(vim.o.lines * 0.8)
    t.win = vim.api.nvim_open_win(t.buf, true, {
      relative = "editor",
      width = width,
      height = height,
      row = math.floor((vim.o.lines - height) / 2) - 1,
      col = math.floor((vim.o.columns - width) / 2),
      style = "minimal",
    })
  else
    vim.cmd(t.direction == "vertical" and "botright vsplit" or "botright split")
    t.win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(t.win, t.buf)
    if t.direction == "vertical" then
      vim.api.nvim_win_set_width(t.win, math.floor(vim.o.columns * 0.4))
    else
      vim.api.nvim_win_set_height(t.win, math.floor(vim.o.lines * 0.3))
    end
  end

  vim.wo[t.win].number = false
  vim.wo[t.win].relativenumber = false
  vim.wo[t.win].signcolumn = "no"
end

local function hide(t)
  if visible(t) then
    pcall(vim.api.nvim_win_close, t.win, false)
  end
  t.win = nil
end

local function start(t)
  t.buf = vim.api.nvim_create_buf(false, true)
  t.cwd = vim.fn.getcwd()
  open_win(t)

  t.job = vim.fn.jobstart(t.cmd, {
    term = true,
    on_exit = function()
      hide(t)
      if alive(t) then
        pcall(vim.api.nvim_buf_delete, t.buf, { force = true })
      end
      forget(t)
      redraw()
    end,
  })

  -- TUIs need their own <esc>, so shadow the global terminal-mode escape.
  if t.tui then
    vim.keymap.set("t", "<esc><esc>", "<esc><esc>", { buffer = t.buf })
  end
end

function M.open(key, opts)
  opts = opts or {}
  local t = terms[key]

  if alive(t) then
    local direction = opts.direction or t.direction
    if visible(t) and direction ~= t.direction then
      hide(t)
    end
    t.direction = direction
    if visible(t) then
      vim.api.nvim_set_current_win(t.win)
    else
      open_win(t)
    end
  else
    if t then
      forget(t)
    end
    t = {
      key = key,
      label = opts.label or key,
      cmd = opts.cmd or vim.o.shell,
      direction = opts.direction or "float",
      tui = opts.tui,
    }
    terms[key] = t
    order[#order + 1] = key
    start(t)
  end

  last = key
  redraw()
  vim.cmd.startinsert()
end

function M.toggle(key, opts)
  local t = terms[key]
  if visible(t) then
    hide(t)
    redraw()
    return
  end
  M.open(key, opts)
end

local function shell_key(n)
  return "shell:" .. n
end

function M.shell(n, opts)
  opts = vim.tbl_extend("force", opts or {}, { label = tostring(n) })
  M.toggle(shell_key(n), opts)
end

function M.new(opts)
  local n = 1
  while terms[shell_key(n)] do
    n = n + 1
  end
  M.shell(n, opts)
end

-- Reopen the active shell in a different layout, creating one if none exist.
function M.relayout(direction)
  local t = terms[last]
  if not alive(t) or t.tui then
    t = shells()[1]
  end
  if not t then
    return M.new({ direction = direction })
  end
  M.open(t.key, { direction = direction })
end

function M.cycle(delta)
  local list = shells()
  if #list < 2 then
    return
  end

  local idx = 1
  for i, t in ipairs(list) do
    if t.key == last then
      idx = i
      break
    end
  end

  local current = terms[last]
  local direction = current and current.direction or nil
  if current then
    hide(current)
  end

  local next_term = list[((idx - 1 + delta) % #list) + 1]
  M.open(next_term.key, { direction = direction })
end

function M.kill(key)
  local t = terms[key or last]
  if not alive(t) then
    return
  end
  if t.job then
    pcall(vim.fn.jobstop, t.job)
  end
  hide(t)
  pcall(vim.api.nvim_buf_delete, t.buf, { force = true })
  forget(t)
  redraw()
end

function M.pick()
  local entries, lookup = {}, {}
  for _, key in ipairs(order) do
    local t = terms[key]
    if alive(t) then
      local line = ("%-12s %s"):format(t.label, t.cwd or "")
      entries[#entries + 1] = line
      lookup[line] = key
    end
  end

  if #entries == 0 then
    return M.new()
  end

  require("fzf-lua").fzf_exec(entries, {
    prompt = "Terminals> ",
    actions = {
      ["default"] = function(selected)
        if selected and selected[1] then
          M.open(lookup[selected[1]])
        end
      end,
      ["ctrl-x"] = function(selected)
        if selected and selected[1] then
          M.kill(lookup[selected[1]])
        end
      end,
      ["ctrl-n"] = function()
        M.new()
      end,
    },
  })
end

return M
