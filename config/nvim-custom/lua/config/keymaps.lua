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

map("n", "<esc>", "<cmd>nohlsearch<cr><esc>", { desc = "Escape and clear hlsearch" })

-- buffers
map("n", "<s-h>", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
map("n", "<s-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "[b", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
map("n", "]b", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Alternate buffer" })
map("n", "<leader>bd", "<cmd>:bd<cr>", { desc = "Delete buffer" })

-- windows
map("n", "<leader>ww", "<c-w>p", { desc = "Other window", remap = true })
map("n", "<leader>wd", "<c-w>c", { desc = "Close window", remap = true })
map("n", "<leader>w-", "<c-w>s", { desc = "Split window below", remap = true })
map("n", "<leader>w|", "<c-w>v", { desc = "Split window right", remap = true })
map("n", "<leader>-", "<c-w>s", { desc = "Split window below", remap = true })
map("n", "<leader>|", "<c-w>v", { desc = "Split window right", remap = true })

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

-- session
map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit all" })

-- diagnostics
-- stylua: ignore start
map("n", "]e", function() vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR }) end, { desc = "Next error" })
map("n", "[e", function() vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR }) end, { desc = "Prev error" })
map("n", "]w", function() vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.WARN }) end, { desc = "Next warn" })
map("n", "[w", function() vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.WARN }) end, { desc = "Prev warn" })
-- stylua: ignore end

map("n", "<leader>xl", "<cmd>lopen<cr>", { desc = "Location list" })
map("n", "<leader>xq", "<cmd>copen<cr>", { desc = "Quickfix list" })

-- toggles
local Utils = require("config.utils")

Utils.toggle("<leader>ud", {
  name = "Diagnostics",
  get = vim.diagnostic.is_enabled,
  set = vim.diagnostic.enable,
})

Utils.toggle("<leader>uf", {
  name = "Autoformat (Global)",
  get = function()
    return vim.g.autoformat == nil or vim.g.autoformat
  end,
  set = function(state)
    vim.g.autoformat = state
    vim.b.autoformat = nil
  end,
})

Utils.toggle("<leader>uF", {
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
})

Utils.toggle("<leader>ub", {
  name = "Dark mode",
  get = function()
    return vim.o.background == "dark"
  end,
  set = function(state)
    vim.o.background = state and "dark" or "light"
  end
})

-- misc
map("n", "<leader>l", "<cmd>Lazy<cr>", { desc = "Lazy package manager" })
