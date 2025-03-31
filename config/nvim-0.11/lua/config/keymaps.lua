local function map(mode, lhs, rhs, opts)
  opts = opts or {}
  opts.silent = opts.silent ~= false
  if opts.remap and not vim.g.vscode then
    opts.remap = nil
  end
  vim.keymap.set(mode, lhs, rhs, opts)
end

-- better up/down
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
map({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })
map({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })

-- better indenting
map("v", "<", "<gv")
map("v", ">", ">gv")

-- https://github.com/mhinz/vim-galore#saner-behavior-of-n-and-n
map("n", "n", "'Nn'[v:searchforward].'zv'", { expr = true, desc = "Next Search Result" })
map("x", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next Search Result" })
map("o", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next Search Result" })
map("n", "N", "'nN'[v:searchforward].'zv'", { expr = true, desc = "Prev Search Result" })
map("x", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev Search Result" })
map("o", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev Search Result" })

-- buffers
map("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Alternate Buffer" })
-- map("n", "<leader>bd", "<cmd>bd<cr>", { desc = "Delete Buffer" })
map("n", "<leader>bD", "<cmd>:bd<cr>", { desc = "Delete Buffer And Window" })

-- windows
map("n", "<leader>-", "<c-w>s", { desc = "Split Window Below", remap = true })
map("n", "<leader>|", "<c-w>v", { desc = "Split Window Right", remap = true })
map("n", "<leader>wd", "<c-w>c", { desc = "Delete Window", remap = true })

-- tabs
map("n", "<leader><tab><tab>", "<cmd>tabnew<cr>", { desc = "New Tab" })
map("n", "<leader><tab>d", "<cmd>tabclose<cr>", { desc = "Close Tab" })
map("n", "[<tab>", "<cmd>tabprevious<cr>", { desc = "Previous Tab" })
map("n", "]<tab>", "<cmd>tabnext<cr>", { desc = "Next Tab" })

map("n", "<esc>", "<cmd>nohlsearch<cr>")

-- terminal
map("t", "<esc><esc>", "<c-\\><c-n>", { desc = "Exit terminal mode" })

-- quit
map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit All" })

-- lazy
map("n", "<leader>l", "<cmd>Lazy<cr>", { desc = "Lazy" })

-- diagnostics
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line Diagnostics" })
map("n", "<leader>cq", vim.diagnostic.setqflist, { desc = "Quickfix Diagnostics" })
map("n", "<leader>cl", vim.diagnostic.setloclist, { desc = "Loclist Diagnostics" })

-- popups/completion
-- stylua: ignore start
map("i", "<tab>", function() return vim.fn.pumvisible() == 1 and "<c-n>" or "<tab>" end, { expr = true })
map("i", "<s-tab>", function() return vim.fn.pumvisible() == 1 and "<c-p>" or "<s-tab>" end, { expr = true })
map("i", "<down>", function() return vim.fn.pumvisible() == 1 and "<c-n>" or "<down>" end, { expr = true })
map("i", "<up>", function() return vim.fn.pumvisible() == 1 and "<c-p>" or "<up>" end, { expr = true })
map("i", "<cr>", function() return vim.fn.pumvisible() == 1 and "<c-y>" or "<cr>" end, { expr = true })
-- stylua: ignore end

-- TODO: toggle options
