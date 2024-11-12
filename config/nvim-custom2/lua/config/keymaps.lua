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

-- stylua: ignore start

map("x", "<leader>p", [["_dP]], { desc = "Paste over" })

-- better up/down
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
map({ "n", "x" }, "<down>", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })
map({ "n", "x" }, "<up>", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })

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
-- map("n", "<s-h>", function() require("config.ui.tabline").prev() end, { desc = "Prev buffer" })
-- map("n", "<s-l>", function() require("config.ui.tabline").next() end, { desc = "Next buffer" })
-- map("n", "[b", function() require("config.ui.tabline").prev() end, { desc = "Prev buffer" })
-- map("n", "]b", function() require("config.ui.tabline").next() end, { desc = "Next buffer" })
-- map("n", "<leader>bn", "<cmd>enew<cr>", { desc = "New buffer" })
-- map("n", "<leader>bd", function() require("config.ui.tabline").close_buffer() end, { desc = "Close buffer" })

map("n", "<s-h>", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
map("n", "<s-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "[b", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
map("n", "]b", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Alternate buffer" })
map("n", "<leader>bD", "<cmd>:bd<cr>", { desc = "Delete buffer" })
map("n", "<leader>bd", function() require("config.utils.bufdelete")() end, { desc = "Delete buffer" })
map("n", "<leader>bo", function() require("config.utils.bufdelete").other() end, { desc = "Delete other buffers" })
map("n", "<leader>bD", "<cmd>:bd<cr>", { desc = "Delete buffer and window" })

-- windows
map("n", "<leader>ww", "<c-w>p", { desc = "Other window", remap = true })
map("n", "<leader>wd", "<c-w>c", { desc = "Close window", remap = true })
map("n", "<leader>w-", "<c-w>s", { desc = "Split window below", remap = true })
map("n", "<leader>w|", "<c-w>v", { desc = "Split window right", remap = true })
map("n", "<leader>-", "<c-w>s", { desc = "Split window below", remap = true })
map("n", "<leader>|", "<c-w>v", { desc = "Split window right", remap = true })

-- resize 
map("n", "<c-up>", "<cmd>resize +2<cr>", { desc = "Increase window height" })
map("n", "<c-down>", "<cmd>resize -2<cr>", { desc = "Decrease window height" })
map("n", "<c-left>", "<cmd>vertical resize -2<cr>", { desc = "Increase window width" })
map("n", "<c-right>", "<cmd>vertical resize +2<cr>", { desc = "Decrease window width" })

-- move lines
map("n", "<a-j>", "<cmd>execute 'move .+' . v:count1<cr>==", { desc = "Move down" })
map("n", "<a-k>", "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", { desc = "Move up" })
map("i", "<a-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move down" })
map("i", "<a-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move up" })
map("v", "<a-j>", ":<c-u>execute \"'<.'>move '>+\" . v:count1<cr>gv=gv", { desc = "Move down" })
map("v", "<a-k>", ":<c-u>execute \"'<.'>move '>-\" . (v:count1 + 1)<cr>gv=gv", { desc = "Move up" })

-- tabs
map("n", "<leader><tab>l", "<cmd>tablast<cr>", { desc = "Last tab" })
map("n", "<leader><tab>f", "<cmd>tabfirst<cr>", { desc = "First tab" })
map("n", "<leader><tab>o", "<cmd>tabonly<cr>", { desc = "Close other tabs" })
map("n", "<leader><tab><tab>", "<cmd>tabnew<cr>", { desc = "New tab" })
map("n", "<leader><tab>]", "<cmd>tabnext<cr>", { desc = "Next tab" })
map("n", "<leader><tab>[", "<cmd>tabprev<cr>", { desc = "Prev tab" })
map("n", "<leader><tab>d", "<cmd>tabclose<cr>", { desc = "Close tab" })

-- terminal keymaps
map("t", "<esc><esc>", "<c-\\><c-n>", { desc = "Exit terminal mode" })
map("n", "<leader>th", function() require("config.utils.terminal")() end, { desc = "Terminal horizontal" })
map("n", "<leader>tv", function() require("config.utils.terminal")() end, { desc = "Terminal vertical" })
map("n", "<leader>tf", function() require("config.utils.terminal")() end, { desc = "Terminal float" })

-- map("n", "<leader>th", function() require("config.utils.term").toggle({ pos = "sp", id = "hterm" }) end, { desc = "Horizontal term" })
-- map("n", "<leader>tv", function() require("config.utils.term").toggle({ pos = "vsp", id = "vterm" }) end, { desc = "Vertical term" })
-- map("n", "<leader>tf", function() require("config.utils.term").toggle({ pos = "float", id = "float_term" }) end, { desc = "Floating term" })

map("n", "<esc>", "<cmd>nohlsearch<cr><esc>", { desc = "Escape and clear hlsearch" })

map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit all" })

map("n", "<leader>l", "<cmd>Lazy<cr>", { desc = "Lazy package manager" })

-- git
if vim.fn.executable("lazygit") == 1 then
  map("n", "<leader>gg", function() require("config.utils.lazygit")() end, { desc = "Lazygit" })
  map("n", "<leader>gb", function() require("config.utils.git").blame_line() end, { desc = "Blame line" })
  map("n", "<leader>gf", function() require("config.utils.lazygit").log_file() end, { desc = "Lazygit file history" })
  map("n", "<leader>gl", function() require("config.utils.lazygit").log() end, { desc = "Lazygit log" })
end

-- diagnostic
local function diagnostic_goto(next, severity)
  local go = next and vim.diagnostic.goto_next or vim.diagnostic.goto_prev
  severity = severity and vim.diagnostic.severity[severity] or nil
  return function()
    go({ severity = severity })
  end
end
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line diagnostics" })
map("n", "]d", diagnostic_goto(true), { desc = "Next diagnostics" })
map("n", "[d", diagnostic_goto(false), { desc = "Prev diagnostics" })
map("n", "]e", diagnostic_goto(true, "ERROR"), { desc = "Next error" })
map("n", "[e", diagnostic_goto(false, "ERROR"), { desc = "Prev error" })
map("n", "]w", diagnostic_goto(true, "WARN"), { desc = "Next warning" })
map("n", "[w", diagnostic_goto(false, "WARN"), { desc = "Prev warning" })

-- quickfix
map("n", "<leader>xl", "<cmd>lopen<cr>", { desc = "Location list " })
map("n", "<leader>xq", "<cmd>copen<cr>", { desc = "Quickfix list" })
map("n", "[q", vim.cmd.cprev, { desc = "Prev quickfix" })
map("n", "]q", vim.cmd.cnext, { desc = "Next quickfix" })
