local function is_tmux()
  return vim.env.TMUX ~= nil and vim.env.TMUX ~= ""
end

local function navigate(dir)
  local win_before = vim.api.nvim_get_current_win()

  local wincmd = ({
    h = "h",
    j = "j",
    k = "k",
    l = "l",
  })[dir]

  vim.cmd.wincmd(wincmd)

  if vim.api.nvim_get_current_win() ~= win_before then
    return
  end

  if not is_tmux() then
    return
  end

  local tmux_dir = ({
    h = "L",
    j = "D",
    k = "U",
    l = "R",
  })[dir]

  vim.system({ "tmux", "select-pane", "-" .. tmux_dir }, {}, nil)
end

vim.keymap.set("n", "<c-h>", function() navigate("h") end, { desc = "Navigate left" })
vim.keymap.set("n", "<c-j>", function() navigate("j") end, { desc = "Navigate down" })
vim.keymap.set("n", "<c-k>", function() navigate("k") end, { desc = "Navigate up" })
vim.keymap.set("n", "<c-l>", function() navigate("l") end, { desc = "Navigate right" })
