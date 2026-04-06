local function navigate(vdir, tdir)
  local win = vim.api.nvim_get_current_win()
  vim.cmd.wincmd(vdir)
  if (vim.env.TMUX ~= nil) and vim.api.nvim_get_current_win() == win then
    vim.system({ "tmux", "select-pane", "-" .. tdir })
  end
end
vim.keymap.set({ "n", "t" }, "<c-h>", function() navigate("h", "L") end)
vim.keymap.set({ "n", "t" }, "<c-j>", function() navigate("j", "D") end)
vim.keymap.set({ "n", "t" }, "<c-k>", function() navigate("k", "U") end)
vim.keymap.set({ "n", "t" }, "<c-l>", function() navigate("l", "R") end)

