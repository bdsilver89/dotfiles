local function map(mode, lhs, rhs, opts)
  local keys = require("lazy.core.handler").handlers.keys

  if not keys.active[keys.parse({ lhs, mode = mode }).id] then
    opts = opts or {}
    opts.silent = opts.silent ~= false
    vim.keymap.set(mode, lhs, rhs, opts)
  end
end

map("n", "<c-d>", "<c-d>zz")
map("n", "<c-u>", "<c-u>zz")

map("n", "<leader>p", [["_dP]])

map("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
map("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

-- splits
map("n", "<c-h>", "<c-w>h", { desc = "Go to left window" })
map("n", "<c-j>", "<c-w>j", { desc = "Go to lower window" })
map("n", "<c-k>", "<c-w>k", { desc = "Go to upper window" })
map("n", "<c-l>", "<c-w>l", { desc = "Go to right window" })

map("n", "<c-up>", "<cmd>resize +2<cr>", { desc = "Increase window height" })
map("n", "<c-left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
map("n", "<c-down>", "<cmd>resize -2<cr>", { desc = "Decreate window height" })
map("n", "<c-right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })

-- windows
map("n", "<leader>ww", "<C-W>p", { desc = "Other window" })
map("n", "<leader>wd", "<C-W>c", { desc = "Delete window" })
map("n", "<leader>w-", "<C-W>s", { desc = "Split window below" })
map("n", "<leader>w|", "<C-W>v", { desc = "Split window right" })
map("n", "<leader>-", "<C-W>s", { desc = "Split window below" })
map("n", "<leader>|", "<C-W>v", { desc = "Split window right" })

-- tabs
map("n", "<leader><tab>l", "<cmd>tablast<cr>", { desc = "Last tab" })
map("n", "<leader><tab>f", "<cmd>tabfirst<cr>", { desc = "First tab" })
map("n", "<leader><tab><tab>", "<cmd>tabnew<cr>", { desc = "New tab" })
map("n", "<leader><tab>]", "<cmd>tabnext<cr>", { desc = "Next tab" })
map("n", "<leader><tab>d", "<cmd>tapclose<cr>", { desc = "Close tab" })
map("n", "<leader><tab>[", "<cmd>tabprev<cr>", { desc = "Prev tab" })

-- buffers
if require("bdsilver89.utils").has("bufferline.nvim") then
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

map("n", "<a-j>", "<cmd>m .+1<cr>==", { desc = "Move down" })
map("n", "<a-k>", "<cmd>m .-2<cr>==", { desc = "Move up" })
map("i", "<a-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move down" })
map("i", "<a-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move up" })
map("v", "<a-j>", ":m '>+1<cr>gv=gv", { desc = "Move down" })
map("v", "<a-k>", ":m '<-2<cr>gv=gv", { desc = "Move up" })

map("n", "<leader>bb", "<cmd>e #e<cr>", { desc = "Switch to alternate buffer" })
map("n", "<leader>br", "<cmd>e!<cr>", { desc = "Reload" })
map("n", "<leader>bc", "<cmd>close<cr>", { desc = "Close" })

map({ "i", "n" }, "<esc>", "<cmd>noh<cr><esc>", { desc = "Escape and clear hlsearch" })

map(
  "n",
  "<leader>ur",
  "<cmd>nohlsearch<bar>diffupdate<bar>normal! <c-L><cr>",
  { desc = "Redraw/clear hlsearch/diff update" }
)

-- sane use of n and N
map("n", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next search result" })
map("x", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next search result" })
map("o", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next search result" })
map("n", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev search result" })
map("x", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev search result" })
map("o", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev search result" })

-- undo break points
map("i", ",", ",<c-g>u")
map("i", ".", ".<c-g>u")
map("i", ";", ";<c-g>u")

-- better indenting
map("v", "<", "<gv")
map("v", ">", ">gv")

map("n", "<leader>l", "<cmd>:Lazy<cr>", { desc = "Lazy" })

map("t", "<esc><esc>", "<c-\\><c-n>", { desc = "Enter normal mode" })

if vim.fn.has("nvim-0.9") == 1 then
  map("n", "<leader>ui", vim.show_pos, { desc = "Inspect Pos" })
end
