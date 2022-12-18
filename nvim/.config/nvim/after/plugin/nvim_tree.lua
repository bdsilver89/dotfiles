vim.g.loaded = 1
vim.g.loaded_netrwPlugin = 1

require('nvim-tree').setup {
  sort_by = 'case_sensitive',
  view = {
    mappings = {
      list = {
        { key = 'u', action = 'dir_up' }
      }
    },
    -- side = right,
    -- width = 40,
    adaptive_size = true,
  },
  renderer = {
    special_files = {},
  },
  filters = {
    dotfiles = false,
  },
  git = {
    enable = true,
    ignore = false,
    timeout = 500,
  },
}

vim.keymap.set('n', '<leader><tab>', '<cmd>NvimTreeToggle<CR>', { desc = '[N]vimTree [T]oggle'})
