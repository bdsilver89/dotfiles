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
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "[b", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
map("n", "]b", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Switch to other buffer" })
map("n", "<leader>`", "<cmd>e #<cr>", { desc = "Switch to other buffer" })
-- map("n", "<leader>bd", "<cmd>bd<cr>", { desc = "Delete buffer" })
-- stylua: ignore
map("n", "<leader>bd", function() Snacks.bufdelete() end, { desc = "Delete Buffer" })
-- stylua: ignore
map("n", "<leader>bo", function() Snacks.bufdelete.other() end, { desc = "Delete Other Buffers" })
map("n", "<leader>bD", "<cmd>:bd<cr>", { desc = "Delete Buffer and Window" })

-- move windows
-- map("n", "<c-h>", "<c-w><c-h>", { desc = "Move focus to left window" })
-- map("n", "<c-j>", "<c-w><c-j>", { desc = "Move focus to right window" })
-- map("n", "<c-k>", "<c-w><c-k>", { desc = "Move focus to lower window" })
-- map("n", "<c-l>", "<c-w><c-l>", { desc = "Move focus to upper window" })

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

map("n", "<esc>", "<cmd>nohlsearch<cr>")

-- terminal
map("t", "<esc><esc>", "<c-\\><c-n>", { desc = "Exit terminal mode" })

-- quit
map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit All" })

-- lazy
map("n", "<leader>l", "<cmd>Lazy<cr>", { desc = "Lazy" })

-- highlights under cursor
map("n", "<leader>ui", vim.show_pos, { desc = "Inspect Pos" })
map("n", "<leader>uI", "<cmd>InspectTree<cr>", { desc = "Inspect Tree" })

-- diagnostic
local diagnostic_goto = function(next, severity)
  local go = next and vim.diagnostic.goto_next or vim.diagnostic.goto_prev
  severity = severity and vim.diagnostic.severity[severity] or nil
  return function()
    go({ severity = severity })
  end
end
map("n", "]d", diagnostic_goto(true), { desc = "Next Diagnostic" })
map("n", "[d", diagnostic_goto(false), { desc = "Prev Diagnostic" })
map("n", "]e", diagnostic_goto(true, "ERROR"), { desc = "Next Error" })
map("n", "[e", diagnostic_goto(false, "ERROR"), { desc = "Prev Error" })
map("n", "]w", diagnostic_goto(true, "WARN"), { desc = "Next Warning" })
map("n", "[w", diagnostic_goto(false, "WARN"), { desc = "Prev Warning" })

map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line Diagnostics" })
map("n", "<leader>cq", vim.diagnostic.setqflist, { desc = "Open diagnostic Quickfix list" })
map("n", "<leader>cl", vim.diagnostic.setloclist, { desc = "Open diagnostic Location list" })
map("n", "<leader>xq", "<cmd>copen<cr>", { desc = "Quickfix List" })
map("n", "<leader>xl", "<cmd>lopen<cr>", { desc = "Location List" })
map("n", "[q", vim.cmd.cprev, { desc = "Previous Quickfix" })
map("n", "]q", vim.cmd.cnext, { desc = "Next Quickfix" })

-- formatting
Snacks.toggle({
  name = "Autoformat (Global)",
  get = function()
    return vim.g.autoformat == nil or vim.g.autoformat
  end,
  set = function(state)
    vim.g.autoformat = state
    vim.b.autoformat = nil
  end,
}):map("<leader>uf")

Snacks.toggle({
  name = "Autoformat (Buffer)",
  get = function()
    local buf = vim.api.nvim_get_current_buf()
    local gaf = vim.g.autoformat
    local baf = vim.b[buf].autoformat

    if baf ~= nil then
      return baf
    end
    return gaf == nil or gaf
  end,
  set = function(state)
    vim.b.autoformat = state
  end,
}):map("<leader>uF")

Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
Snacks.toggle.diagnostics():map("<leader>ud")
Snacks.toggle.line_number():map("<leader>ul")
Snacks.toggle.treesitter():map("<leader>uT")
Snacks.toggle.option("background", { off = "light", on = "dark", name = "Dark Background" }):map("<leader>ub")
if vim.lsp.inlay_hint then
  Snacks.toggle.inlay_hints():map("<leader>uh")
end

-- lazygit
-- stylua: ignore start
if vim.fn.executable("lazygit") == 1 then
  map("n", "<leader>gg", function() Snacks.lazygit() end, { desc = "Lazygit" })
  map("n", "<leader>gf", function() Snacks.lazygit.log_file() end, { desc = "Lazygit Current File History" })
  map("n", "<leader>gl", function() Snacks.lazygit.log() end, { desc = "Lazygit Log" })
end
-- stylua: ignore end

-- stylua: ignore start
map("n", "<leader>gb", function() Snacks.git.blame_line() end, { desc = "Git Blame Line" })
map({ "n", "x" }, "<leader>gB", function() Snacks.gitbrowse() end, { desc = "Git Browse (open)" })
-- stylua: ignore end

-- floating term
-- stylua: ignore start
map("n", "<leader>ft", function() Snacks.terminal() end, { desc = "Terminal" })
map("n", "<c-/>", function() Snacks.terminal(nil) end, { desc = "Terminal" })
map("n", "<c-_>", function() Snacks.terminal(nil) end, { desc = "which_key_ignore" })
-- stylua: ignore end

-- Terminal Mappings
map("t", "<C-/>", "<cmd>close<cr>", { desc = "Hide Terminal" })
map("t", "<c-_>", "<cmd>close<cr>", { desc = "which_key_ignore" })
