vim.pack.add({
  "https://github.com/stevearc/oil.nvim",
  "https://github.com/refractalize/oil-git-status.nvim",
  "https://github.com/nvim-tree/nvim-web-devicons",
  "https://github.com/nvim-tree/nvim-tree.lua",
})

require("oil").setup({
  skip_confirm_for_simple_edits = true,
  win_options = {
    signcolumn = "yes:2",
  },
  view_options = {
    show_hidden = true,
  },
  watch_for_changes = true,
})

require("oil-git-status").setup({
  show_ignored = false,
})

require("nvim-tree").setup({
  hijack_cursor = true,
  sync_root_with_cwd = true,
  update_focused_file = {
    enable = true,
  },
  renderer = {
    indent_markers = {
      enable = true,
    },
  },
})

vim.keymap.set("n", "-", "<cmd>Oil<cr>", { desc = "Explorer (oil)" })
vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<cr>", { desc = "Explorer (tree)" })
