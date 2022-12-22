-- vim.g.loaded = 1
-- vim.g.loaded_netrwPlugin = 1

local status, nvim_tree = pcall(require, 'nvim-tree')
if (not status) then return end

nvim_tree.setup {
  sort_by = 'case_sensitive',
  hijack_netrw = false,
  view = {
    mappings = {
      list = {
        { key = 'u', action = 'dir_up' }
      }
    },
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
