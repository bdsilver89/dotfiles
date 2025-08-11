local add = MiniDeps.add

add("christoomey/vim-tmux-navigator")
add("stevearc/oil.nvim")
add({ source = "nvim-neo-tree/neo-tree.nvim", checkout = "3.x" })

require("oil").setup({
  win_options = {
    signcolumn = "yes:2",
  },
  view_options = {
    show_hidden = true,
  },
})

vim.keymap.set("n", "-", "<cmd>Oil<cr>", { desc = "Oil explorer" })

require("neo-tree").setup({
  close_if_last_window = true,
  source_selector = {
    winbar = true,
    sources = { { source = "filesystem" } },
  },
  filesystem = {
    filtered_items = {
      hide_dotfiles = false,
      hide_gitignored = false,
      hide_hidden = false,
    },
  },
})

vim.keymap.set("n", "<leader>e", "<cmd>Neotree toggle<cr>", { desc = "File explorer" })
