local terminal_wins = {}

local function create_float()
  local max_height = vim.api.nvim_win_get_height(0)
  local max_width = vim.api.nvim_win_get_width(0)

  local height = math.floor(max_height * 0.9)
  local width = math.floor(max_width * 0.9)

  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    height = height,
    width = width,
    col = math.floor((max_width - width) / 2),
    row = math.floor((max_height - height) / 2),
  })
  return buf, win
end

local function create_terminal(cmd)
  local term_win = nil
  if cmd then
    if type(cmd) == "string" then
      local parts = vim.split(cmd, " ")
      if terminal_wins[parts[1]] then
        term_win = terminal_wins[parts[1]]
      end
    end
  end

  if term_win == nil then
    local _, win = create_float()
    term_win = win
  end

  if cmd == "" then
    cmd = nil
  end

  vim.api.nvim_win_call(term_win, function()
    vim.cmd.term(cmd or nil)
    vim.cmd("startinsert")
  end)
end

vim.api.nvim_create_user_command("Floaty", function(opts)
  create_terminal(opts.args)
end, {
  nargs = "*",
  desc = "Open a floating terminal",
})

if vim.fn.executable("lazygit") == 1 then
  vim.api.nvim_create_user_command("Lazygit", function()
    create_terminal("lazygit")
  end, {
    nargs = "*",
    desc = "Open lazygit in floating terminal",
  })

  vim.keymap.set("n", "<leader>gg", function()
    create_terminal("lazygit")
  end, { desc = "Lazygit" })
end
