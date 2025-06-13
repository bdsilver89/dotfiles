-- Uses lazy.nvim's keys handler to make things simpler here
-- stylua: ignore
require("utils").lazy_keymap({
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

  -- diagnostics
  { "grd", vim.diagnostic.open_float, desc = "vim.diagnostic.open_float()" },
  { "grq", vim.diagnostic.setqflist, desc = "vim.diagnostic.setqflist()" },
  { "grl", vim.diagnostic.setloclist, desc = "vim.diagnostic.setloclist()" },
  {
    "<leader>xl",
    function()
      local ok, err = pcall(vim.fn.getloclist(0, { winid = 0 }).winid ~= 0 and vim.cmd.lclose or vim.cmd.lopen)
      if not ok and err then
        vim.notify(err, vim.log.levels.ERROR)
      end
    end,
    desc = "Location List",
  },
  {
    "<leader>xq",
    function()
      local ok, err = pcall(vim.fn.getqflist({ winid = 0 }).winid ~= 0 and vim.cmd.cclose or vim.cmd.copen)
      if not ok and err then
        vim.notify(err, vim.log.levels.ERROR)
      end
    end,
    desc = "Quickfix List",
  },

  -- terminal
  { "<c-/>", "<cmd>close<cr>", mode = "t", desc = "Hide Terminal" },
  { "<c-_>", "<cmd>close<cr>", mode = "t", desc = "which_key_ignore" },

  { "<esc>", "<cmd>nohlsearch<cr>" },
  { "<leader>l", "<cmd>Lazy<cr>", desc = "Lazy" },
  { "<leader>qq", "<cmd>qa<cr>", desc = "Quit all" },
})
