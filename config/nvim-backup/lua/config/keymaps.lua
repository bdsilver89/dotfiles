local utils = require("config.utils")

local function map(mode, lhs, rhs, opts)
  opts = opts or {}
  opts.silent = opts.silent ~= false
  if opts.remap and not vim.g.vscode then
    opts.remap = nil
  end
  vim.keymap.set(mode, lhs, rhs, opts)
end

map("x", "<leader>p", [["_dP]], { desc = "paste" })
map({ "n", "v" }, "<leader>y", [["+y]], { desc = "yank" })
map("n", "<leader>Y", [["+Y]], { desc = "yank" })
map({ "n", "v" }, "<leader>d", [["_d]], { desc = "delete" })

-- better up/down
map("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
map("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })


-- line join
map("n", "J", "mzJ`z")

-- centering when jumping
map("n", "<c-d>", "<c-d>zz")
map("n", "<c-u>", "<c-u>zz")
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")

-- better indenting
map("v", "<", "<gv")
map("v", ">", ">gv")

-- move to windows
-- map("n", "<c-h>", "<c-w>h", { desc = "Go to left window" })
-- map("n", "<c-j>", "<c-w>j", { desc = "Go to lower window" })
-- map("n", "<c-k>", "<c-w>k", { desc = "Go to upper window" })
-- map("n", "<c-l>", "<c-w>l", { desc = "Go to right window" })

-- resize windows
map("n", "<c-up>", "<cmd>resize +2<cr>", { desc = "Increase window height" })
map("n", "<c-down>", "<cmd>resize -2<cr>", { desc = "Decrease window height" })
map("n", "<c-left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
map("n", "<c-right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })

-- move lines
-- map("n", "<a-j>", "<cmd>m .+1<cr>==", { desc = "move down" })
-- map("n", "<a-k>", "<cmd>m .-2<cr>==", { desc = "move up" })
-- map("i", "<a-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move down" })
-- map("i", "<a-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move up" })
-- map("v", "<a-j>", ":m '>+1<cr>gv=gv", { desc = "Move down" })
-- map("v", "<a-k>", ":m '<-2<cr>gv=gv", { desc = "Move up" })
map("v", "J", ":m '>+1<cr>gv=gv", { desc = "Move line up" })
map("v", "K", ":m '>-2<cr>gv=gv", { desc = "Move line down" })

-- windows
map("n", "<leader>ww", "<c-w>p", { desc = "Previous window" })
map("n", "<leader>wd", "<c-w>c", { desc = "Close window" })
map("n", "<leader>w-", "<c-w>s", { desc = "Split window horizontal" })
map("n", "<leader>w|", "<c-w>v", { desc = "Split window vertical" })
map("n", "<leader>-", "<c-w>s", { desc = "Split window horizontal" })
map("n", "<leader>|", "<c-w>v", { desc = "Split window vertical" })

-- buffers
if require("config.utils").has("bufferline.nvim") then
  map("n", "<s-h>", "<cmd>BufferLineCyclePrev<cr>", { desc = "Prev buffer" })
  map("n", "<s-l>", "<cmd>BufferLineCycleNext<cr>", { desc = "Next buffer" })
  map("n", "[b", "<cmd>BufferLineCyclePrev<cr>", { desc = "Prev buffer" })
  map("n", "]b", "<cmd>BufferLineCycleNext<cr>", { desc = "Next buffer" })
else
  map("n", "<s-h>", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
  map("n", "<s-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })
  map("n", "[b", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
  map("n", "]b", "<cmd>bnext<cr>", { desc = "Next buffer" })
end
--map("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Delete buffer" })
--map("n", "<leader>bD", "<cmd>bdelete!<cr>", { desc = "Delete buffer (force)" })
map("n", "<leader>bb", "<cmd>e#<cr>", { desc = "Alternate buffer" })
map("n", "<leader>br", "<cmd>e!<cr>", { desc = "Reload buffer" })
map("n", "<leader>bc", "<cmd>close<cr>", { desc = "Close buffer" })
map("n", "<leader>bn", "<cmd>enew<cr>", { desc = "New buffer" })

-- tabs
map("n", "<leader><tab>l", "<cmd>tablast<cr>", { desc = "Last tab" })
map("n", "<leader><tab>f", "<cmd>tabfirst<cr>", { desc = "First tab" })
map("n", "<leader><tab><tab>", "<cmd>tabnew<cr>", { desc = "New tab" })
map("n", "<leader><tab>]", "<cmd>tabnext<cr>", { desc = "Next tab" })
map("n", "<leader><tab>d", "<cmd>tabclose<cr>", { desc = "Close tab" })
map("n", "<leader><tab>[", "<cmd>tabprev<cr>", { desc = "Prev tab" })

-- terminal
map("t", "<esc><esc>", "<c-\\><c-n>", { desc = "Enter normal mode" })
map("t", "<c-h>", "<cmd>wincmd h<cr>", { desc = "Go to left window" })
map("t", "<c-j>", "<cmd>wincmd j<cr>", { desc = "Go to lower window" })
map("t", "<c-k>", "<cmd>wincmd k<cr>", { desc = "Go to upper window" })
map("t", "<c-l>", "<cmd>wincmd l<cr>", { desc = "Go to right window" })
map("t", "<c-/>", "<cmd>close<cr>", { desc = "Hide terminal" })
map("t", "<c-_>", "<cmd>close<cr>", { desc = "which_key_ignore" })

map({ "i", "n" }, "<esc>", "<cmd>noh<cr><esc>", { desc = "Escape and clear hlsearch" })

map("n", "<leader>ur", "<cmd>nohlsearch<bar>diffupdate<bar>normal! <c-L><cr>",
  { desc = "Redraw/clear hlsearch/diff update" })

if vim.fn.has("nvim-0.9.0") == 1 then
  map("n", "<leader>ui", vim.show_pos, { desc = "Inspect position" })
end

map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit all" })

-- toggle options

map("n", "<leader>us", function() utils.toggle("spell") end, { desc = "Toggle spelling" })
map("n", "<leader>uw", function() utils.toggle("wrap") end, { desc = "Toggle word wrap" })
map("n", "<leader>ud", function() utils.toggle_diagnostics() end, { desc = "Toggle diagnostics" })
map("n", "<leader>ul", function()
  utils.toggle("relativenumber", true)
  utils.toggle("number", true)
end, { desc = "Toggle line numbers" })

map("n", "<leader>K", "<cmd>norm! K<cr>", { desc = "Keywordprg" })

local conceallevel = vim.o.conceallevel > 0 and vim.o.conceallevel or 3
map("n", "<leader>uc", function() utils.toggle("conceallevel", false, { 0, conceallevel }) end,
  { desc = "Toggle conceallevel" })

if vim.lsp.inlay_hint then
  map("n", "<leader>uh", function() vim.lsp.inlay_hint(0, nil) end, { desc = "Toggle inlay hints" })
end

map("n", "<leader>l", "<cmd>Lazy<cr>", { desc = "Lazy" })
