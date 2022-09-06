local status, harpoon = pcall(require, 'harpoon')
if (not status) then return end

vim.keymap.set('n', '<leader>a', function()
    require('harpoon.mark').add_file()
  end,
  { noremap = true, silent = true }
)

vim.keymap.set('n', '<C-f>', function()
    require('harpoon.ui').toggle_quick_menu()
  end,
  { noremap = true, silent = true }
)

vim.keymap.set('n', '<C-h>', function()
    require('harpoon.ui').nav_file(1)
  end,
  { noremap = true, silent = true }
)

vim.keymap.set('n', '<C-j>', function()
    require('harpoon.ui').nav_file(2)
  end,
  { noremap = true, silent = true }
)

vim.keymap.set('n', '<C-k>', function()
    require('harpoon.ui').nav_file(3)
  end,
  { noremap = true, silent = true }
)

vim.keymap.set('n', '<C-l>', function()
    require('harpoon.ui').nav_file(4)
  end,
  { noremap = true, silent = true }
)
