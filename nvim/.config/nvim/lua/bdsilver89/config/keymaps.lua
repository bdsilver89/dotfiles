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

-- better up/down
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
map("n", "<leader><tab>d", "<cmd>tabclose<cr>", { desc = "Close tab" })
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

map("n", "<leader>bb", "<cmd>e#<cr>", { desc = "Switch to alternate buffer" })
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

-- lazy.nvim
map("n", "<leader>l", "<cmd>:Lazy<cr>", { desc = "Lazy" })

-- new file
map("n", "<leader>fn", "<cmd>enew<cr>", { desc = "New File" })

map("n", "<leader>xl", "<cmd>lopen<cr>", { desc = "Location List" })
map("n", "<leader>xq", "<cmd>copen<cr>", { desc = "Quickfix List" })

if not require("bdsilver89.utils").has("trouble.nvim") then
  map("n", "[q", vim.cmd.cprev, { desc = "Previous quickfix" })
  map("n", "]q", vim.cmd.cnext, { desc = "Next quickfix" })
end

-- toggle options
-- stylua: ignore start
map("n", "<leader>uf", require("bdsilver89.plugins.lsp.format").toggle, { desc = "Toggle format on save" })
map("n", "<leader>us", function() require("bdsilver89.utils").toggle("spell") end, { desc = "Toggle spelling" })
map("n", "<leader>uw", function() require("bdsilver89.utils").toggle("wrap") end, { desc = "Toggle word wrap" })
map("n", "<leader>ul", function() require("bdsilver89.utils").toggle("relativenumber", true) end, { desc = "Toggle relative line numbers" })
local conceallevel = vim.o.conceallevel > 0 and vim.o.conceallevel or 3
map("n", "<leader>uc", function() require("bdsilver89.utils").toggle("conceallevel", false, {0, conceallevel}) end, { desc = "Toggle conceallevel" })
if vim.lsp.buf.inlay_hint then
   map("n", "<leader>uh", function() vim.lsp.buf.inlay_hint(0, nil) end, { desc = "Toggle inlay hints" })
end
-- stylua: ignore end

-- TODO: lazygit shortcut

-- quit
map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit all" })

-- highlights under cursor
if vim.fn.has("nvim-0.9.0") == 1 then
  map("n", "<leader>ui", vim.show_pos, { desc = "Inspect Pos" })
end

if vim.fn.has("nvim-0.9") == 1 then
  map("n", "<leader>ui", vim.show_pos, { desc = "Inspect Pos" })
end

-- terminal mappings
map("t", "<esc><esc>", "<c-\\><c-n>", { desc = "Enter normal mode" })
