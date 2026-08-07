vim.pack.add({
  "https://github.com/nvim-tree/nvim-tree.lua",
  "https://github.com/stevearc/oil.nvim",
})

require("nvim-tree").setup()

vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<cr>", { desc = "File explorer" })

require("oil").setup({
  skip_confirm_for_simple_edits = true,
  view_options = {
    show_hidden = true,
  },
})

vim.keymap.set("n", "-", "<cmd>Oil<cr>", { desc = "Oil explorer" })
