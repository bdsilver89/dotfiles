-- Uses lazy.nvim's keys handler to make things simpler here
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

  -- buffers
  { "<leader>bd", function() require("utils").bufdelete() end, desc = "Delete buffer" },
  { "<leader>bD", function() require("utils").bufdelete_all() end, desc = "Delete all buffers" },
  { "<leader>bo", function() require("utils").bufdelete_others() end, desc = "Delete other buffers" },

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
    "<leader>xd",
    function()
      local state = not vim.diagnostic.is_enabled()
      vim.diagnostic.enable(state)
      vim.notify(
        string.format("***%s diagnostics***", state and "Enabled" or "Disabled"),
        state and vim.log.levels.INFO or vim.log.levels.WARN
      )
    end,
    desc = "Toggle diagnostics",
  },

  -- formatting
  {
    "<leader>uf",
    function()
      local state = not vim.g.autoformat
      vim.g.autoformat = state
      vim.notify(
        string.format("***%s autoformatting***", state and "Enabled" or "Disabled"),
        state and vim.log.levels.INFO or vim.log.levels.WARN
      )
    end,
    desc = "Toggle autoformat",
  },

  -- terminal
  {
    "<c-/>",
    function()
      require("term").float_term(vim.o.shell, { cwd = vim.fn.expand("%:p:h")})
    end,
    mode = { "n", "t" },
    desc = "Toggle floating terminal"
  },
  {
    "<c-_>",
    function()
      require("term").float_term(vim.o.shell, { cwd = vim.fn.expand("%:p:h")})
    end,
    mode = { "n", "t" },
    desc = "which_key_ignore"
  },
  { "<leader>gg", function() require("term").lazygit() end, mode = { "n", "t" }, desc = "Lazygit" },
  { "<leader>gl", function() require("term").lazygit({ "log" }) end, mode = { "n", "t" }, desc = "Lazygit log" },
  {
    "<leader>gf",
    function()
      local file = vim.trim(vim.api.nvim_buf_get_name(0))
      require("term").lazygit({ "-f", file }) end,
    mode = { "n", "t" },
    desc = "Lazygit file log"
  },

  { "<esc>", "<cmd>nohlsearch<cr>" },
  { "<leader>l", "<cmd>Lazy<cr>", desc = "Lazy" },
  { "<leader>qq", "<cmd>qa<cr>", desc = "Quit all" },
}

local Keys = require("lazy.core.handler.keys")
for _, keys in pairs(Keys.resolve(keymaps)) do
  local opts = Keys.opts(keys)
  ---@diagnostic disable-next-line: inject-field
  opts.silent = opts.silent ~= false
  ---@diagnostic disable-next-line: param-type-mismatch
  vim.keymap.set(keys.mode or "n", keys.lhs, keys.rhs, opts)
end
