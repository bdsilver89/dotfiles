-- Remap for dealing with word wrap and adding jumps to the jumplist.
vim.keymap.set("n", "j", [[(v:count > 1 ? 'm`' . v:count : 'g') . 'j']], { expr = true })
vim.keymap.set("n", "k", [[(v:count > 1 ? 'm`' . v:count : 'g') . 'k']], { expr = true })

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

vim.keymap.set("n", "<esc>", "<cmd>nohlsearch<cr>")

-- Open the package manager.
vim.keymap.set("n", "<leader>l", "<cmd>Lazy<cr>", { desc = "Lazy" })

-- Quit
vim.keymap.set("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit all" })
