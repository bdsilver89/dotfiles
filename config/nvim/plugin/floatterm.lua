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

local function set_win_opts(win)
  local wo = vim.wo[win]
  wo.number = false
  wo.relativenumber = false
  wo.cursorline = false
  wo.spell = false
  wo.statuscolumn = ""
  wo.foldcolumn = "0"
  wo.winblend = 0
  wo.winhighlight = "Normal:Normal,FloatBorder:FloatBorder"
end

local function open(cmd)
  local key = cmd or "shell"

  if terminals[key] then
    local state = terminals[key]
    if vim.api.nvim_win_is_valid(state.win) then
      vim.api.nvim_win_hide(state.win)
      return
    end
    if vim.api.nvim_buf_is_valid(state.buf) then
      state.win = vim.api.nvim_open_win(state.buf, true, float_opts())
      set_win_opts(state.win)
      vim.cmd.startinsert()
      return
    end
    terminals[key] = nil
  end

  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, true, float_opts())
  set_win_opts(win)

  vim.fn.jobstart(cmd or vim.o.shell, { term = true })
  vim.cmd.startinsert()

  terminals[key] = { buf = buf, win = win }

  vim.api.nvim_create_autocmd("TermClose", {
    buffer = buf,
    once = true,
    callback = function()
      local state = terminals[key]
      terminals[key] = nil
      if state then
        pcall(vim.api.nvim_win_close, state.win, true)
      end
      vim.schedule(function()
        pcall(vim.api.nvim_buf_delete, buf, { force = true })
      end)
    end,
  })
end

vim.api.nvim_create_autocmd("VimResized", {
  callback = function()
    for _, state in pairs(terminals) do
      if vim.api.nvim_win_is_valid(state.win) then
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
  vim.keymap.set("n", "<leader>td", function() open("lazydocker") end, { desc = "Lazydocker" })
end
if vim.fn.executable("lazysql") == 1 then
  vim.keymap.set("n", "<leader>tq", function() open("lazysql") end, { desc = "Lazysql" })
end
vim.keymap.set({"n", "t"}, "<C-_>", function() open() end, { desc = "Float Terminal" })
-- stylua: ignore end
