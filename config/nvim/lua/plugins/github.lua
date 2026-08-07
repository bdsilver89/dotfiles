vim.pack.add({
  "https://github.com/nvim-lua/plenary.nvim",
  "https://github.com/pwntester/octo.nvim",
})

require("octo").setup({
  picker = "fzf-lua",
})

vim.keymap.set("n", "<leader>gp", "<cmd>Octo pr list<cr>", { desc = "Pull requests" })
vim.keymap.set("n", "<leader>gi", "<cmd>Octo issue list<cr>", { desc = "Issues" })
vim.keymap.set("n", "<leader>gr", "<cmd>Octo review start<cr>", { desc = "Start PR review" })
