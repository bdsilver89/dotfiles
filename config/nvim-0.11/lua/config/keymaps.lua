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

-- resize window using <ctrl> arrow keys
map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase Window Height" })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease Window Height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease Window Width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase Window Width" })

-- move lines
map("n", "<A-j>", "<cmd>execute 'move .+' . v:count1<cr>==", { desc = "Move Down" })
map("n", "<A-k>", "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", { desc = "Move Up" })
map("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move Down" })
map("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move Up" })
map("v", "<A-j>", ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv", { desc = "Move Down" })
map("v", "<A-k>", ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv", { desc = "Move Up" })

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
map("t", "<c-h>", "<cmd>wincmd h<cr>")
map("t", "<c-j>", "<cmd>wincmd j<cr>")
map("t", "<c-k>", "<cmd>wincmd k<cr>")
map("t", "<c-l>", "<cmd>wincmd l<cr>")

-- quit
map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit All" })

-- lazy
map("n", "<leader>l", "<cmd>Lazy<cr>", { desc = "Lazy" })

-- diagnostics
map("n", "grd", vim.diagnostic.open_float, { desc = "vim.diagnostic.open_float()" })
map("n", "grq", vim.diagnostic.setqflist, { desc = "vim.diagnostic.setqflist()" })
map("n", "grl", vim.diagnostic.setloclist, { desc = "vim.diagnostic.setloclist()" })

-- popups/completion
-- stylua: ignore start
-- map("i", "<tab>", function() return vim.fn.pumvisible() == 1 and "<c-n>" or "<tab>" end, { expr = true })
-- map("i", "<s-tab>", function() return vim.fn.pumvisible() == 1 and "<c-p>" or "<s-tab>" end, { expr = true })
-- map("i", "<down>", function() return vim.fn.pumvisible() == 1 and "<c-n>" or "<down>" end, { expr = true })
-- map("i", "<up>", function() return vim.fn.pumvisible() == 1 and "<c-p>" or "<up>" end, { expr = true })
-- map("i", "<cr>", function() return vim.fn.pumvisible() == 1 and "<c-y>" or "<cr>" end, { expr = true })

map("i", "<c-[>", "<c-x><c-[>")
map("i", "<c-f>", "<c-x><c-f>")
map("i", "<c-l>", "<c-x><c-l>")
map("i", "<c-d>", "<c-x><c-d>")
-- stylua: ignore end
