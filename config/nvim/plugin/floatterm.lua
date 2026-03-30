local terminals = {}

local function float_opts()
  local width = math.floor(vim.o.columns * 0.85)
  local height = math.floor(vim.o.lines * 0.85)
  return {
    relative = "editor",
    width = width,
    height = height,
    col = math.floor((vim.o.columns - width) / 2),
    row = math.floor((vim.o.lines - height) / 2),
    style = "minimal",
    border = "none",
    zindex = 50,
  }
end

local function split_opts(style)
  if style == "right" then
    return { split = "right", width = math.floor(vim.o.columns * 0.4) }
  end
  return { split = "below", height = math.floor(vim.o.lines * 0.3) }
end

local function set_win_opts(win, style)
  local wo = vim.wo[win]
  wo.number = false
  wo.relativenumber = false
  wo.cursorline = false
  wo.spell = false
  wo.statuscolumn = ""
  wo.foldcolumn = "0"
  if style == "float" then
    wo.winblend = 0
    wo.winhighlight = "Normal:Normal,FloatBorder:FloatBorder"
  end
end

local function create_win(buf, style)
  local win
  if style == "float" then
    win = vim.api.nvim_open_win(buf, true, float_opts())
  else
    win = vim.api.nvim_open_win(buf, true, split_opts(style))
  end
  set_win_opts(win, style)
  return win
end

local function open(cmd, style)
  style = style or "float"
  local key = (cmd or "shell") .. ":" .. style

  if terminals[key] then
    local state = terminals[key]
    if vim.api.nvim_win_is_valid(state.win) then
      vim.api.nvim_win_hide(state.win)
      return
    end
    if vim.api.nvim_buf_is_valid(state.buf) then
      state.win = create_win(state.buf, style)
      vim.cmd.startinsert()
      return
    end
    terminals[key] = nil
  end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].filetype = "floatterm"
  local win = create_win(buf, style)

  vim.fn.jobstart(cmd or vim.o.shell, { term = true })
  vim.cmd.startinsert()

  terminals[key] = { buf = buf, win = win, style = style }

  vim.api.nvim_create_autocmd("TermClose", {
    buffer = buf,
    once = true,
    callback = function()
      terminals[key] = nil
      pcall(vim.api.nvim_win_close, win, true)
      vim.schedule(function()
        pcall(vim.api.nvim_buf_delete, buf, { force = true })
      end)
    end,
  })
end

vim.api.nvim_create_autocmd("VimResized", {
  callback = function()
    for _, state in pairs(terminals) do
      if state.style == "float" and vim.api.nvim_win_is_valid(state.win) then
        vim.api.nvim_win_set_config(state.win, float_opts())
      end
    end
  end,
})

vim.api.nvim_create_user_command("FloatTerm", function(opts)
  local cmd = opts.args ~= "" and opts.args or nil
  open(cmd)
end, { nargs = "?" })

-- stylua: ignore start
if vim.fn.executable("lazygit") == 1 then
  vim.keymap.set("n", "<leader>gg", function() open("lazygit") end, { desc = "Lazygit" })
end
if vim.fn.executable("lazydocker") == 1 then
  vim.keymap.set("n", "<leader>gd", function() open("lazydocker") end, { desc = "Lazydocker" })
end
if vim.fn.executable("lazysql") == 1 then
  vim.keymap.set("n", "<leader>gq", function() open("lazysql") end, { desc = "Lazysql" })
end
vim.keymap.set("n", "<leader>ft", function() open(nil, "float") end, { desc = "Float Terminal" })
vim.keymap.set("n", "<leader>fT", function() open(nil, "bottom") end, { desc = "Bottom Terminal" })
-- stylua: ignore end
