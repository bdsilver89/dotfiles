vim.pack.add({
  "https://github.com/stevearc/oil.nvim",
  "https://github.com/ibhagwan/fzf-lua",
})

require("oil").setup({
  keymaps = {
    ["<C-h>"] = false,
  },
})
vim.keymap.set("n", "-", "<cmd>Oil<cr>", { desc = "Oil" })

require("fzf-lua").setup({
  keymap = {
    fzf = {
      ["ctrl-q"] = "select-all+accept",
    },
  },
})
vim.keymap.set("n", "<leader><leader>", "<cmd>FzfLua files<cr>", { desc = "Files" })
vim.keymap.set("n", "<leader>,", "<cmd>FzfLua buffers<cr>", { desc = "Buffers" })
vim.keymap.set("n", "<leader>/", "<cmd>FzfLua live_grep<cr>", { desc = "Grep" })

