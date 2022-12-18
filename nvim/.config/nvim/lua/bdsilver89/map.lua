-- vim.keymap.set('n', 'x', '"_x')

vim.keymap.set('x', '<leader>p', [["_dP]], { desc = 'Delete to void register and then paste' })
vim.keymap.set({'n','v'}, '<leader>y', [["+y]], { desc = 'Copy to system clipboard' })
vim.keymap.set('n', '<leader>Y', [["+Y]], { desc = 'Copy to system clipboard' })
vim.keymap.set({'n','v'}, '<leader>d', [["_d]], { desc = 'Delete to void register'})

vim.keymap.set('n', 'n', 'nzzzv', { desc = 'Keep search next centered' })
vim.keymap.set('n', 'N', 'Nzzzv', { desc = 'Keep search prev centered' })
vim.keymap.set('n', 'J', 'mzJ`z', { desc = 'Appends current line with space and then merges line below' })
vim.keymap.set('n', '<C-d>', '<C-d>zz', { desc = 'Scroll down and center' })
vim.keymap.set('n', '<C-u>', '<C-u>zz', { desc = 'Scroll up and center' })

vim.keymap.set('n', 'Q', '<nop>')

vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv", { desc = 'Move highlighted text down one line' })
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv", { desc = 'Move highlighted text up one line' })

vim.keymap.set({'n', 'x'}, '+', '<C-a>', { desc = 'Increment number' })
vim.keymap.set({'n', 'x'}, '-', '<C-x>', { desc = 'Decrement number' })

vim.keymap.set('n', '<C-a>', 'gg<S-v>G', { desc = 'Highlight entire buffer contents' })

vim.keymap.set('n', '<leader>[', '<C-o>', { desc = 'Prev in jumplist' })
vim.keymap.set('n', '<leader>]', '<C-i>', { desc = 'Next in jumplist' })

-- new tab (use leader to avoid conflict with t til char)
-- vim.keymap.set('n', '<leader>te', ':tabedit')
-- vim.keymap.set('n', '<leader>tc', ':tabclose')

-- vim.keymap.set('n', '<C-k>', '<cmd>cnext<CR>zz')
-- vim.keymap.set('n', '<C-j>', '<cmd>cprev<CR>zz')
-- vim.keymap.set('n', '<leader>k', '<cmd>lnext<CR>zz')
-- vim.keymap.set('n', '<leader>j', '<cmd>lprev<CR>zz')

-- vim.keymap.set('n', '<leader>x', '<cmd>!chmod +x %<CR>', { silent = true })

vim.keymap.set('n', 'ss', ':split<Return>', { desc = 'Split window' })
vim.keymap.set('n', 'sv', ':vsplit<Return>', { desc = 'Vertical split window' })

-- move window
vim.keymap.set('n', 'sh', '<C-w>h', { desc = 'Move pane left' })
vim.keymap.set('n', 'sj', '<C-w>j', { desc = 'Move pane down '})
vim.keymap.set('n', 'sk', '<C-w>k', { desc = 'Move pane up' })
vim.keymap.set('n', 'sl', '<C-w>l', { desc = 'Move pane right' })

-- resize window
vim.keymap.set('n', '<C-w><left>', '<C-w><', { desc = 'Resize pane left' })
vim.keymap.set('n', '<C-w><right>', '<C-w>>', { desc = 'Resize pane right' })
vim.keymap.set('n', '<C-w><up>', '<C-w>+', { desc = 'Resize pane up' })
vim.keymap.set('n', '<C-w><down>', '<C-w>-', { desc = 'Resize pane down' })
