-- vim-tmux-navigator style pane navigation, no plugin required.
-- Uses `tmux is-active` to only forward navigation to tmux when we're at a
-- vim window edge; otherwise just moves between vim windows.

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

  vim.fn.system({ "tmux", "select-pane", "-" .. tmux_dir })
end

vim.keymap.set("n", "<C-h>", function() navigate("h") end, { desc = "Navigate left (tmux-aware)" })
vim.keymap.set("n", "<C-j>", function() navigate("j") end, { desc = "Navigate down (tmux-aware)" })
vim.keymap.set("n", "<C-k>", function() navigate("k") end, { desc = "Navigate up (tmux-aware)" })
vim.keymap.set("n", "<C-l>", function() navigate("l") end, { desc = "Navigate right (tmux-aware)" })
