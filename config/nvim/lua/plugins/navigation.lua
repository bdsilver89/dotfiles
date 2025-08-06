local add = MiniDeps.add

add("christoomey/vim-tmux-navigator")
add("stevearc/oil.nvim")

require("oil").setup({
  win_options = {
    signcolumn = "yes:2",
  },
  view_options = {
    show_hidden = true,
  },
})

vim.keymap.set("n", "-", "<cmd>Oil<cr>", { desc = "Oil explorer" })
