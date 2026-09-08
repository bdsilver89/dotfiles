vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
vim.keymap.set("n", "<down>", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set("n", "<up>", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

vim.keymap.set("n", "<c-d>", "<c-d>zz")
vim.keymap.set("n", "<c-u>", "<c-u>zz")
vim.keymap.set("n", "N", "Nzzzv")
vim.keymap.set("n", "n", "nzzzv")

vim.keymap.set("n", "<leader>q", "<cmd>q<cr>")
vim.keymap.set("n", "<leader>w", "<cmd>w<cr>")
vim.keymap.set("n", "<leader>bd", "<cmd>bd<cr>")

vim.keymap.set("n", "<leader>xq", function()
  local success, err = pcall(vim.fn.getqflist({ winid = 0 }).winid ~= 0 and vim.cmd.cclose or vim.cmd.copen)
  if not success and err then
    vim.notify(err, vim.log.levels.ERROR)
  end
end)
vim.keymap.set("n", "<leader>xl", function()
  local success, err = pcall(vim.fn.getloclist(0, { winid = 0 }).winid ~= 0 and vim.cmd.lclose or vim.cmd.lopen)
  if not success and err then
    vim.notify(err, vim.log.levels.ERROR)
  end
end)

vim.keymap.set("x", "<", "<gv")
vim.keymap.set("x", ">", ">gv")

vim.keymap.set("t", "<esc><esc>", "<c-\\><c-n>")

vim.keymap.set("i", ",", ",<c-g>u")
vim.keymap.set("i", ".", ".<c-g>u")
vim.keymap.set("i", ";", ";<c-g>u")

vim.keymap.set({ "i", "s" }, "<tab>", function()
  if vim.fn.pumvisible() == 1 then
    return "<c-n>"
  elseif vim.snippet.active({ direction = 1 }) then
    return "<cmd>lua vim.snippet.jump(1)<cr>"
  else
    return "<tab>"
  end
end, { expr = true, silent = true })

vim.keymap.set({ "i", "s" }, "<s-tab>", function()
  if vim.fn.pumvisible() == 1 then
    return "<c-p>"
  elseif vim.snippet.active({ direction = -1 }) then
    return "<cmd>lua vim.snippet.jump(-1)<cr>"
  else
    return "<s-tab>"
  end
end, { expr = true, silent = true })

vim.keymap.set("i", "<cr>", function()
  if vim.fn.pumvisible() == 1 then
    return "<c-y>"
  else
    return "<cr>"
  end
end, { expr = true, silent = true })

vim.keymap.set("n", "<esc>", function()
  local ns = vim.api.nvim_create_namespace("nvim.multicursor")
  if #vim.api.nvim_buf_get_extmarks(0, ns, 0, -1, { limit = 1 }) > 0 then
    vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
  else
    vim.cmd("noh")
  end
end)
