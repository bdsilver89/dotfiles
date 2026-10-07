local fzf = require("fzf-lua")

fzf.setup({})

vim.keymap.set("n", "<leader><space>", fzf.files)
vim.keymap.set("n", "<leader>/", fzf.live_grep)
vim.keymap.set("n", "<leader>,", fzf.buffers)
vim.keymap.set("n", "<leader>.", fzf.resume)
