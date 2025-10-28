local function map(mode, lhs, rhs, opts)
  opts = opts or {}
  opts.silent = opts.silent ~= false
  vim.keymap.set(mode, lhs, rhs, opts)
end

-- remap for dealing with word wrap and adding jumps to jumplist
map("n", "j", [[(v:count > 1 ? 'm`' . v:count : 'g') . 'j']], { expr = true })
map("n", "k", [[(v:count > 1 ? 'm`' . v:count : 'g') . 'k']], { expr = true })

-- keeping cursor centered
map("n", "<c-d>", "<c-d>zz", { desc = "Scroll downwards" })
map("n", "<c-u>", "<c-u>zz", { desc = "Scroll upwards" })
map("n", "n", "nzzzv", { desc = "Next result" })
map("n", "N", "Nzzzv", { desc = "Prevresult" })

-- indent while remaining in visual mode
map("v", "<", "<gv")
map("v", ">", ">gv")

-- windows
map("n", "<leader>-", "<c-w>s", { desc = "Split window below", remap = true })
map("n", "<leader>|", "<c-w>v", { desc = "Split window right", remap = true })
map("n", "<leader>wd", "<c-w>c", { desc = "Close window", remap = true })

map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase Window Height" })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease Window Height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease Window Width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase Window Width" })

-- tabs
map("n", "<leader><tab><tab>", "<cmd>tabnew<cr>", { desc = "New tab" })
map("n", "<leader><tab>d", "<cmd>tabclose<cr>", { desc = "Close tab" })
map("n", "[<tab>", "<cmd>tabprev<cr>", { desc = "Prev tab" })
map("n", "]<tab>", "<cmd>tabnext<cr>", { desc = "Next tab" })

map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit" })

map("n", "<leader>l", "<cmd>Lazy<cr>", { desc = "Lazy" })
