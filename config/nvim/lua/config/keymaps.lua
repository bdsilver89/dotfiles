local function map(mode, lhs, rhs, opts)
  local modes = type(mode) == "string" and { mode } or mode
  if #modes > 0 then
    opts = opts or {}
    opts.silent = opts.silent ~= false
    if opts.remap and not vim.g.vscode then
      opts.remap = nil
    end
    vim.keymap.set(modes, lhs, rhs, opts)
  end
end

-- better up/down for word wrap
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
map({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
map({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

-- better behavior of N and n
map("n", "n", "'Nn'[v:searchforward].'zv'", { expr = true, desc = "Next search result" })
map("x", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next search result" })
map("o", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next search result" })
map("n", "N", "'nN'[v:searchforward].'zv'", { expr = true, desc = "Prev search result" })
map("x", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev search result" })
map("o", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev search result" })

-- window resize
map("n", "<c-up>", "<cmd>resize +2<cr>", { desc = "Increase window height" })
map("n", "<c-down>", "<cmd>resize -2<cr>", { desc = "Decrease window height" })
map("n", "<c-left>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })
map("n", "<c-right>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })

-- move lines
map("n", "<a-j>", "<cmd>m .+1<cr>==", { desc = "Move line down" })
map("n", "<a-k>", "<cmd>m .-2<cr>==", { desc = "Move line up" })
map("i", "<a-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move line down" })
map("i", "<a-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move line up" })
map("v", "<a-j>", ":m '>+1<cr>gv=gv", { desc = "Move line down" })
map("v", "<a-k>", ":m '<-2<cr>gv=gv", { desc = "Move line up" })

-- buffers
map("n", "<s-h>", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
map("n", "<s-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "[b", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
map("n", "]b", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Close buffer" })
map("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Alternate buffer" })
map("n", "<leader>`", "<cmd>e #<cr>", { desc = "Alternate buffer" })

-- window splits
map("n", "<leader>ww", "<c-w>p", { desc = "Other window", remap = true })
map("n", "<leader>wd", "<c-w>c", { desc = "Close window", remap = true })
map("n", "<leader>w-", "<c-w>s", { desc = "Split window below", remap = true })
map("n", "<leader>-", "<c-w>s", { desc = "Split window below", remap = true })
map("n", "<leader>w|", "<c-w>v", { desc = "Split window right", remap = true })
map("n", "<leader>|", "<c-w>v", { desc = "Split window right", remap = true })

-- tabs
map("n", "<leader><tab>l", "<cmd>tablast<cr>", { desc = "Last tab" })
map("n", "<leader><tab>f", "<cmd>tabfirst<cr>", { desc = "First tab" })
map("n", "<leader><tab><tab>", "<cmd>tabnew<cr>", { desc = "New tab" })
map("n", "<leader><tab>]", "<cmd>tabnext<cr>", { desc = "Next tab" })
map("n", "<leader><tab>[", "<cmd>tabprev<cr>", { desc = "Prev tab" })
map("n", "<leader><tab>d", "<cmd>tabclose<cr>", { desc = "Close tab" })

-- terminal
map("t", "<esc><esc>", "<c-\\><c-n>", { desc = "Enter normal mode" })
map("t", "<c-h>", "<cmd>wincmd h<cr>", { desc = "Go to left window" })
map("t", "<c-j>", "<cmd>wincmd j<cr>", { desc = "Go to lower window" })
map("t", "<c-k>", "<cmd>wincmd k<cr>", { desc = "Go to upper window" })
map("t", "<c-l>", "<cmd>wincmd l<cr>", { desc = "Go to right window" })

-- better indenting
map("v", "<", "<gv")
map("v", ">", ">gv")

-- clear hlsearch
map({ "i", "n" }, "<esc>", "<cmd>noh<cr><esc>", { desc = "Escape and clear hlsearch", noremap = true })

-- redraw, cleare hlsearch and update diff
map("n", "<leader>ur", "<cmd>noh<bar>diffupdate<bar>normal! <c-l><cr>", { desc = "Redraw/clear-hlsearch/diff-update" })

map("n", "<leader>l", "<cmd>Lazy<cr>", { desc = "Lazy" })

map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit all" })

map("n", "<leader>xl", "<cmd>lopen<cr>", { desc = "Location list" })
map("n", "<leader>xq", "<cmd>copen<cr>", { desc = "Quickfix list" })

map("n", "[q", vim.cmd.cprev, { desc = "Prev quickfix" })
map("n", "]q", vim.cmd.cnext, { desc = "Next quickfix" })

-- diagnostics
local function diagnostic_goto(next, severity)
  local go = next and vim.diagnostic.goto_next or vim.diagnostic.goto_prev
  severity = severity and vim.diagnostic.severity[severety] or nil
  return function()
    go({ severity = severity })
  end
end
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line diagnostics" })
map("n", "]d", diagnostic_goto(true), { desc = "Next diagnostics" })
map("n", "[d", diagnostic_goto(false), { desc = "Prev diagnostics" })
map("n", "]e", diagnostic_goto(true, "ERROR"), { desc = "Next error" })
map("n", "[e", diagnostic_goto(false, "ERROR"), { desc = "Prev error" })
map("n", "]w", diagnostic_goto(true, "WARN"), { desc = "Next warn" })
map("n", "[w", diagnostic_goto(false, "WARN"), { desc = "Prev warn" })
