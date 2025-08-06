-- remap for dealing with word wrap and adding jumps to jumplist
vim.keymap.set("n", "j", [[(v:count > 1 ? 'm`' . v:count : 'g') . 'j']], { expr = true })
vim.keymap.set("n", "k", [[(v:count > 1 ? 'm`' . v:count : 'g') . 'k']], { expr = true })

-- keeping cursor centered
vim.keymap.set("n", "<c-d>", "<c-d>zz", { desc = "Scroll downwards" })
vim.keymap.set("n", "<c-u>", "<c-u>zz", { desc = "Scroll upwards" })
vim.keymap.set("n", "n", "nzzzv", { desc = "Next result" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Prevresult" })

-- indent while remaining in visual mode
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")

-- windows
vim.keymap.set("n", "<leader>-", "<c-w>s", { desc = "Split window below", remap = true })
vim.keymap.set("n", "<leader>|", "<c-w>v", { desc = "Split window right", remap = true })
vim.keymap.set("n", "<leader>wd", "<c-w>c", { desc = "Close window", remap = true })

vim.keymap.set("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase Window Height" })
vim.keymap.set("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease Window Height" })
vim.keymap.set("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease Window Width" })
vim.keymap.set("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase Window Width" })

-- tabs
vim.keymap.set("n", "<leader><tab><tab>", "<cmd>tabnew<cr>", { desc = "New tab" })
vim.keymap.set("n", "<leader><tab>d", "<cmd>tabclose<cr>", { desc = "Close tab" })
vim.keymap.set("n", "[<tab>", "<cmd>tabprev<cr>", { desc = "Prev tab" })
vim.keymap.set("n", "]<tab>", "<cmd>tabnext<cr>", { desc = "Next tab" })

-- diagnostics
vim.keymap.set("n", "gf", vim.diagnostic.open_float, { desc = "vim.diagnostic.open_float()" })
vim.keymap.set("n", "gq", vim.diagnostic.setqflist, { desc = "vim.diagnostic.setqflist()" })
vim.keymap.set("n", "gl", vim.diagnostic.setloclist, { desc = "vim.diagnostic.setloclist()" })
vim.keymap.set("n", "<leader>xl", function()
  local ok, err = pcall(vim.fn.getloclist(0, { winid = 0 }).winid ~= 0 and vim.cmd.lclose or vim.cmd.lopen)
  if not ok and err then
    vim.notify(err, vim.log.levels.ERROR)
  end
end, { desc = "Location List" })
vim.keymap.set("n", "<leader>xq", function()
  local ok, err = pcall(vim.fn.getqflist({ winid = 0 }).winid ~= 0 and vim.cmd.cclose or vim.cmd.copen)
  if not ok and err then
    vim.notify(err, vim.log.levels.ERROR)
  end
end, { desc = "Quickfix List" })

-- terminal
vim.keymap.set("t", "<esc><esc>", "<c-\\><c-n>", { desc = "Exit Terminal Mode" })

vim.keymap.set("n", "<esc>", "<cmd>nohlsearch<cr>")
vim.keymap.set("n", "<leader>w", "<cmd>w<cr>", { desc = "Write" })
vim.keymap.set("n", "<leader>q", "<cmd>q<cr>", { desc = "Quit window" })
vim.keymap.set("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit all" })
