local terminals = {}

local function create_floating_window(opts)
  opts = opts or {}
  local width = opts.width or math.floor(vim.o.columns * 0.8)
  local height = opts.height or math.floor(vim.o.lines * 0.8)
  local col = math.floor((vim.o.columns - width) / 2)
  local row = math.floor((vim.o.lines - height) / 2)

  local buf = nil
  if vim.api.nvim_buf_is_valid(opts.buf) then
    buf = opts.buf
  else
    buf = vim.api.nvim_create_buf(false, true)
  end

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    col = col,
    row = row,
    style = "minimal",
  })

  return { buf = buf, win = win }
end

local function toggle_terminal(name, cmd)
  name = name or "default"
  local term = terminals[name] or { buf = -1, win = -1 }

  if vim.api.nvim_win_is_valid(term.win) then
    vim.api.nvim_win_hide(term.win)
    return
  end

  term = create_floating_window({ buf = term.buf })
  terminals[name] = term

  if vim.bo[term.buf].buftype ~= "terminal" then
    vim.cmd.terminal(cmd)
    vim.keymap.set("n", "q", function()
      vim.api.nvim_win_hide(term.win)
    end, { buffer = term.buf })
  end
  vim.cmd.startinsert()
end

vim.api.nvim_create_user_command("Floaterminal", function(opts)
  local name = opts.args ~= "" and opts.args or nil
  toggle_terminal(name, name)
end, { nargs = "?" })

if vim.fn.executable("lazygit") == 1 then
  vim.keymap.set("n", "<leader>gg", function()
    toggle_terminal("lazygit", "lazygit")
  end, { desc = "Lazygit" })
end

vim.keymap.set({ "n", "t" }, "<C-/>", function()
  toggle_terminal()
end, { desc = "Terminal" })
vim.keymap.set({ "n", "t" }, "<C-_>", function()
  toggle_terminal()
end, { desc = "Terminal" })
