vim.keymap.set("n", "<esc>", "<cmd>nohlsearch<cr>")

vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")

vim.keymap.set({ "i", "s" }, "<tab>", function()
  if vim.fn.pumvisible() == 1 then
    return "<c-n>"
  elseif vim.snippet.active({ direction = 1 }) then
    vim.snippet.jump(1)
    return ""
  end
  return "<tab>"
end, { expr = true })

vim.keymap.set({ "i", "s" }, "<s-tab>", function()
  if vim.fn.pumvisible() == 1 then
    return "<c-p>"
  elseif vim.snippet.active({ direction = -1 }) then
    vim.snippet.jump(-1)
    return ""
  end
  return "<s-tab>"
end, { expr = true })

vim.keymap.set("i", "<cr>", function()
  if vim.fn.pumvisible() == 1 then
    return "<c-y>"
  end
  return "<cr>"
end, { expr = true })

