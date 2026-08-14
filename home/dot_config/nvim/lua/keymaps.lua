vim.keymap.set("n", "<esc>", "<cmd>nohlsearch<cr>")

vim.keymap.set("t", "<esc>", "<c-\\><c-n>")

vim.keymap.set("x", "<", "<gv")
vim.keymap.set("x", ">", ">gv")

vim.keymap.set("n", "<leader>d", function()
  vim.diagnostic.setqflist()
  vim.cmd("copen")
end, { silent = true })

for _, d in ipairs({ "h", "j", "k", "l" }) do
  vim.keymap.set("n", "<C-" .. d .. ">", "<C-w>" .. d)
end
