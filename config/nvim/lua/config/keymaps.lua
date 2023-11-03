local function map(mode, lhs, rhs, opts)
  local modes = type(mode) == "string" and { mode } or mode
  opts = opts or {}
  opts.silent = opts.silent ~= false
  if opts.remap and not vim.g.vscode then
    opts.remap = nil
  end
  vim.keymap.set(modes, lhs, rhs, opts)
end

-- map({ "n", "v" }, "<space>", "<nop>")

map({ "i", "n" }, "<esc>", "<cmd>noh<cr><esc>", { desc = "Escape and clear hlsearch" })

map("n", "<leader>l", "<cmd>Lazy<cr>", { desc = "Lazy" })
map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit all" })

-- centering when jumping
map("n", "<c-d>", "<c-d>zz")
map("n", "<c-u>", "<c-u>zz")

-- better up/down
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

-- better indenting
map("v", "<", "<gv")
map("v", ">", ">gv")

-- https://github.com/mhinz/vim-galore#saner-behavior-of-n-and-n
map("n", "n", "'Nn'[v:searchforward].'zv'", { expr = true, desc = "Next search result" })
map("x", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next search result" })
map("o", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next search result" })
map("n", "N", "'nN'[v:searchforward].'zv'", { expr = true, desc = "Prev search result" })
map("x", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev search result" })
map("o", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev search result" })

-- move selected lines
map("x", "K", ":move '<-2<cr>gv-gv", { silent = true })
map("x", "J", ":move '>+1<cr>gv-gv", { silent = true })

-- buffers
map("n", "<s-h>", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
map("n", "<s-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "[b", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
map("n", "]b", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Other buffer" })
map("n", "<leader>bd", "<cmd>bd<cr>", { desc = "Delete buffer" })

-- window movement
-- map("n", "<c-h>", "<c-w>h", { desc = "Go to left window", remap = true })
-- map("n", "<c-j>", "<c-w>j", { desc = "Go to lower window", remap = true })
-- map("n", "<c-k>", "<c-w>k", { desc = "Go to upper window", remap = true })
-- map("n", "<c-l>", "<c-w>l", { desc = "Go to right window", remap = true })

-- window resize
map("n", "<c-up>", "<cmd>resize +2<cr>", { desc = "Increase window height" })
map("n", "<c-down>", "<cmd>resize -2<cr>", { desc = "Decrease window height" })
map("n", "<c-left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
map("n", "<c-right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })

map("n", "<leader>ww", "<c-w>p", { desc = "Other window", remap = true })
map("n", "<leader>wd", "<c-w>c", { desc = "Delete window", remap = true })

-- window splits
map("n", "<leader>w-", "<c-w>s", { desc = "Split window horizontal", remap = true })
map("n", "<leader>w|", "<c-w>v", { desc = "Split window vertical", remap = true })
map("n", "<leader>-", "<c-w>s", { desc = "Split window horizontal", remap = true })
map("n", "<leader>|", "<c-w>v", { desc = "Split window vertical", remap = true })

-- tabs
map("n", "<leader><tab>l", "<cmd>tablast<cr>", { desc = "Last Tab" })
map("n", "<leader><tab>f", "<cmd>tabfirst<cr>", { desc = "First Tab" })
map("n", "<leader><tab><tab>", "<cmd>tabnew<cr>", { desc = "New Tab" })
map("n", "<leader><tab>]", "<cmd>tabnext<cr>", { desc = "Next Tab" })
map("n", "<leader><tab>d", "<cmd>tabclose<cr>", { desc = "Close Tab" })
map("n", "<leader><tab>[", "<cmd>tabprevious<cr>", { desc = "Previous Tab" })

-- terminals
map("t", "<esc><esc>", "<c-\\><c-n>", { desc = "Enter Normal Mode" })
map("t", "<C-h>", "<cmd>wincmd h<cr>", { desc = "Go to left window" })
map("t", "<C-j>", "<cmd>wincmd j<cr>", { desc = "Go to lower window" })
map("t", "<C-k>", "<cmd>wincmd k<cr>", { desc = "Go to upper window" })
map("t", "<C-l>", "<cmd>wincmd l<cr>", { desc = "Go to right window" })
map("t", "<C-/>", "<cmd>close<cr>", { desc = "Hide Terminal" })
map("t", "<c-_>", "<cmd>close<cr>", { desc = "which_key_ignore" })

-- formatting

-- diagnostics
-- stylua: ignore start
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line diagnostic" })
map("n", "]d", function() vim.diagnostic.goto_next({ severity = nil }) end, { desc = "Next diagnostic" })
map("n", "[d", function() vim.diagnostic.goto_prev({ severity = nil }) end, { desc = "Prev diagnostic" })
map("n", "]e", function() vim.diagnostic.goto_next({ severity = vim.diagnostic.severity["ERROR"] }) end, { desc = "Next error" })
map("n", "[e", function() vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity["ERROR"] }) end, { desc = "Prev error" })
map("n", "]w", function() vim.diagnostic.goto_next({ severity = vim.diagnostic.severity["WARN"] }) end, { desc = "Next warning" })
map("n", "[w", function() vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity["WARN"] }) end, { desc = "Prev warning" })
-- stylua: ignore end

-- options
-- toggle spell
-- toggle wrap
-- toggle relative number
-- toggle number
-- toggle diagnostic
-- toggle conceal level

if vim.lsp.inlay_hint then
  map("n", "<leader>uh", function()
    vim.lsp.inlay_hint(0, nil)
  end, { desc = "Toggle inlay hints" })
end

-- map("n", "<leader>uT", function()
--   if vim.b.ts_highlight then
--     vim.treesitter.stop()
--   else
--     vim.treesitter.start()
--   end
-- end, { desc = "Toggle treesitter highlight" })

map("n", "<leader>ui", vim.show_pos, { desc = "Inspect pos" })
