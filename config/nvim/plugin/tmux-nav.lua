local tmux = vim.env.TMUX ~= nil

local directions = {
  h = "L",
  j = "D",
  k = "U",
  l = "R",
}
local function navigate(dir)
  local win = vim.api.nvim_get_current_win()
  vim.cmd.wincmd(dir)
  if tmux and vim.api.nvim_get_current_win() == win then
    vim.fn.system({ "tmux", "select-pane", "-" .. directions[dir] })
  end
end

for dir, _ in pairs(directions) do
  vim.keymap.set({ "n", "t" }, "<C-" .. dir .. ">", function()
    navigate(dir)
  end, { desc = "Navigate " .. dir })
end
