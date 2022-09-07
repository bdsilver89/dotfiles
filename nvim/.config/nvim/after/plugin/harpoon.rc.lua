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

vim.keymap.set('n', '<leader>l', function()
    require('harpoon.ui').nav_file(4)
  end,
  { noremap = true, silent = true }
)

-- commands and terminals
vim.keymap.set('n', '<leader>M', function()
    require('harpoon.cmd-ui').toggle_quick_menu()
  end,
  { noremap = true, silent = true} )

vim.keymap.set('n', '<leader>t', function()
    require('harpoon.term').gotoTerminal(1)
  end,
  { noremap = true, silent = true }
)

vim.keymap.set('n', '<leader>s', function()
    require('harpoon.term').gotoTerminal(2)
  end,
  { noremap = true, silent = true }
)

vim.keymap.set('n', '<leader>r', function()
    require('harpoon.term').gotoTerminal(3)
  end,
  { noremap = true, silent = true }
)

vim.keymap.set('n', '<leader>a', function()
    require('harpoon.term').gotoTerminal(4)
  end,
  { noremap = true, silent = true }
)
