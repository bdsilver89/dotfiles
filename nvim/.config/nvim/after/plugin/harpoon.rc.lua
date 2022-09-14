local status, harpoon = pcall(require, 'harpoon')
if (not status) then return end

-- windows
vim.keymap.set('n', '<leader>m', function()
    require('harpoon.mark').add_file()
  end,
  { noremap = true, silent = true }
)

vim.keymap.set('n', '<leader>h', function()
    require('harpoon.ui').toggle_quick_menu()
  end,
  { noremap = true, silent = true }
)

vim.keymap.set('n', '<leader>n', function()
    require('harpoon.ui').nav_file(1)
  end,
  { noremap = true, silent = true }
)

vim.keymap.set('n', '<leader>e', function()
    require('harpoon.ui').nav_file(2)
  end,
  { noremap = true, silent = true }
)

vim.keymap.set('n', '<leader>i', function()
    require('harpoon.ui').nav_file(3)
  end,
  { noremap = true, silent = true }
)

vim.keymap.set('n', '<leader>o', function()
    require('harpoon.ui').nav_file(4)
  end,
  { noremap = true, silent = true }
)

-- commands and.tmuxinals
vim.keymap.set('n', '<leader>M', function()
    require('harpoon.cmd-ui').toggle_quick_menu()
  end,
  { noremap = true, silent = true} )

vim.keymap.set('n', '<leader>t', function()
    require('harpoon.tmux').gotoTerminal(1)
  end,
  { noremap = true, silent = true }
)

vim.keymap.set('n', '<leader>s', function()
    require('harpoon.tmux').gotoTerminal(2)
  end,
  { noremap = true, silent = true }
)

vim.keymap.set('n', '<leader>r', function()
    require('harpoon.tmux').gotoTerminal(3)
  end,
  { noremap = true, silent = true }
)

vim.keymap.set('n', '<leader>a', function()
    require('harpoon.tmux').gotoTerminal(4)
  end,
  { noremap = true, silent = true }
)
