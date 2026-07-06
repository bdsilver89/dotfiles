vim.pack.add({
  "https://github.com/ibhagwan/fzf-lua",
})

require("fzf-lua").setup()

vim.keymap.set("n", "<leader><space>", "<cmd>FzfLua files<cr>")
vim.keymap.set("n", "<leader>/", "<cmd>FzfLua live_grep<cr>")
vim.keymap.set("n", "<leader>:", "<cmd>FzfLua command_history<cr>")
vim.keymap.set("n", "<leader>,", "<cmd>FzfLua buffers<cr>")
