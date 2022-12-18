local mark = require('harpoon.mark')
local ui = require('harpoon.ui')

vim.keymap.set('n', '<leader>a', mark.add_file, { desc = 'Harpoon: [A]dd' })
vim.keymap.set('n', '<leader>h', ui.toggle_quick_menu, { desc = '[H]arpoon: UI' })


vim.keymap.set('n', '<leader>n', function() ui.nav_file(1) end, { desc = 'Harpoon: nav file 1' })
vim.keymap.set('n', '<leader>e', function() ui.nav_file(2) end, { desc = 'Harpoon: nav file 2' })
vim.keymap.set('n', '<leader>i', function() ui.nav_file(3) end, { desc = 'Harpoon: nav file 3' })
vim.keymap.set('n', '<leader>o', function() ui.nav_file(4) end, { desc = 'Harpoon: nav file 4' })
