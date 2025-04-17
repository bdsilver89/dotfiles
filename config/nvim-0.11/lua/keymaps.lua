-- Remap for dealing with word wrap and adding jumps to the jumplist.
vim.keymap.set("n", "j", [[(v:count > 1 ? 'm`' . v:count : 'g') . 'j']], { expr = true })
vim.keymap.set("n", "k", [[(v:count > 1 ? 'm`' . v:count : 'g') . 'k']], { expr = true })

-- -- https://github.com/mhinz/vim-galore#saner-behavior-of-n-and-n
-- vim.keymap.set("n", "n", "'Nn'[v:searchforward].'zv'", { expr = true, desc = "Next Search Result" })
-- vim.keymap.set("x", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next Search Result" })
-- vim.keymap.set("o", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next Search Result" })
-- vim.keymap.set("n", "N", "'nN'[v:searchforward].'zv'", { expr = true, desc = "Prev Search Result" })
-- vim.keymap.set("x", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev Search Result" })
-- vim.keymap.set("o", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev Search Result" })

-- Keeping the cursor centered.
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll downwards" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll upwards" })
vim.keymap.set("n", "n", "nzzzv", { desc = "Next result" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous result" })

-- Indent while remaining in visual mode.
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")

-- Buffers
vim.keymap.set("n", "<leader>bd", function()
  require("utils").bufdelete()
end, { desc = "Delete buffer" })

vim.keymap.set("n", "<leader>bD", function()
  require("utils").bufdelete_all()
end, { desc = "Delete all buffers" })

vim.keymap.set("n", "<leader>bo", function()
  require("utils").bufdelete_others()
end, { desc = "Delete other buffers" })

-- Windows
vim.keymap.set("n", "<leader>-", "<c-w>s", { desc = "Split Window Below", remap = true })
vim.keymap.set("n", "<leader>|", "<c-w>v", { desc = "Split Window Right", remap = true })
vim.keymap.set("n", "<leader>wd", "<c-w>c", { desc = "Delete Window", remap = true })

-- Tabs
vim.keymap.set("n", "<leader><tab><tab>", "<cmd>tabnew<cr>", { desc = "New Tab" })
vim.keymap.set("n", "<leader><tab>d", "<cmd>tabclose<cr>", { desc = "Close Tab" })
vim.keymap.set("n", "[<tab>", "<cmd>tabprevious<cr>", { desc = "Previous Tab" })
vim.keymap.set("n", "]<tab>", "<cmd>tabnext<cr>", { desc = "Next Tab" })

-- Diagnostics
vim.keymap.set("n", "grd", vim.diagnostic.open_float, { desc = "vim.diagnostic.open_float()" })
vim.keymap.set("n", "grq", vim.diagnostic.setqflist, { desc = "vim.diagnostic.setqflist()" })
vim.keymap.set("n", "grl", vim.diagnostic.setloclist, { desc = "vim.diagnostic.setloclist()" })

vim.keymap.set("n", "<leader>xd", function()
  local state = not vim.diagnostic.is_enabled()
  vim.diagnostic.enable(state, filter)
  vim.notify(
    string.format("***%s diagnostics***", state and "Enabled" or "Disabled"),
    state and vim.log.levels.INFO or vim.log.levels.WARN
  )
end, { desc = "Toggle diagnostics" })

-- Formatting
vim.keymap.set("n", "<leader>cf", function()
  local state = not vim.g.autoformat
  vim.g.autoformat = state
  vim.notify(
    string.format("***%s auto-formatting***", state and "Enabled" or "Disabled"),
    state and vim.log.levels.INFO or vim.log.levels.WARN
  )
end, { desc = "Toggle auto-formatting" })

-- Terminal
local float_term = function()
  require("float_term").float_term(vim.o.shell, { cwd = vim.fn.expand("%:p:h") })
end

vim.keymap.set({ "n", "t" }, "<c-/>", float_term, { desc = "Toggle floating terminal" })
vim.keymap.set({ "n", "t" }, "<c-_>", float_term, { desc = "which_key_ignore" })

vim.keymap.set({ "n", "t" }, "<leader>gg", function()
  require("float_term").lazygit()
end, { desc = "Lazygit" })

vim.keymap.set({ "n", "t" }, "<leader>gl", function()
  require("float_term").lazygit({ "log" })
end, { desc = "Lazygit Log" })

vim.keymap.set({ "n", "t" }, "<leader>gf", function()
  local file = vim.trim(vim.api.nvim_buf_get_name(0))
  require("float_term").lazygit({ "-f", file })
end, { desc = "Lazygit file log" })

vim.keymap.set("n", "<esc>", "<cmd>nohlsearch<cr>")

-- Open the package manager.
vim.keymap.set("n", "<leader>l", "<cmd>Lazy<cr>", { desc = "Lazy" })

-- Quit
vim.keymap.set("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit all" })
