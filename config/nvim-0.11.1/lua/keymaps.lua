-- stylua: ignore
local keymaps = {
  -- remap for dealing with word wrap and adding jumps to jumplist
  { "j", [[(v:count > 1 ? 'm`' . v:count : 'g') . 'j']], expr = true },
  { "k", [[(v:count > 1 ? 'm`' . v:count : 'g') . 'k']], expr = true },

  -- https://github.com/mhinz/vim-galore#saner-behavior-of-n-and-n
  { "n", "'Nn'[v:searchforward].'zv'", mode = "n", expr = true, desc = "Next search result" },
  { "n", "'Nn'[v:searchforward]", mode = "x", expr = true, desc = "Next search result" },
  { "n", "'Nn'[v:searchforward]", mode = "o", expr = true, desc = "Next search result" },
  { "N", "'nN'[v:searchforward].'zv'", mode = "n", expr = true, desc = "Prev search result" },
  { "N", "'nN'[v:searchforward]", mode = "x", expr = true, desc = "Prev search result" },
  { "N", "'nN'[v:searchforward]", mode = "o", expr = true, desc = "Prev search result" },

  -- keeping cursor centered
  { "<c-d>", "<c-d>zz", desc = "Scroll downwards" },
  { "<c-u>", "<c-u>zz", desc = "Scroll upwards" },
  { "n", "nzzzv", desc = "Next result" },
  { "N", "Nzzzv", desc = "Prevresult" },

  -- indent while remaining in visual mode
  { "<", "<gv", mode = "v" },
  { ">", ">gv", mode = "v" },

  -- windows
  { "<leader>-", "<c-w>s", desc = "Split window below", remap = true },
  { "<leader>|", "<c-w>v", desc = "Split window right", remap = true },
  { "<leader>wd", "<c-w>c", desc = "Close window", remap = true },

  -- tabs
  { "<leader><tab><tab>", "<cmd>tabnew<cr>", desc = "New tab" },
  { "<leader><tab>d", "<cmd>tabclose<cr>", desc = "Close tab" },
  { "[<tab>", "<cmd>tabprev<cr>", desc = "Prev tab" },
  { "]<tab>", "<cmd>tabnext<cr>", desc = "Next tab" },

  { "<esc>", "<cmd>nohlsearch<cr>" },
  { "<leader>l", "<cmd>Lazy<cr>", desc = "Lazy" },
  { "<leader>qq", "<cmd>qa<cr>", desc = "Quit all" },
}

-- use lazy.nvim's keymap setter
local Keys = require("lazy.core.handler.keys")
for _, keys in pairs(Keys.resolve(keymaps)) do
  local opts = Keys.opts(keys)
  ---@diagnostic disable-next-line: inject-field
  opts.silent = opts.silent ~= false
  ---@diagnostic disable-next-line: param-type-mismatch
  vim.keymap.set(keys.mode or "n", keys.lhs, keys.rhs, opts)
end

