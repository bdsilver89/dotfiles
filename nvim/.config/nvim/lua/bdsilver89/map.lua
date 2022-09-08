local keymap = vim.keymap

keymap.set('n', 'x', '"_x')

-- move
keymap.set('v', 'J', ":m '>+1<CR>gv=gv", {noremap = true})
keymap.set('v', 'K', ":m '<-2<CR>gv=gv", {noremap = true})

-- increment/decrement
keymap.set('n', '+', '<C-a>')
keymap.set('n', '-', '<C-x>')

-- select all
keymap.set('n', '<C-a>', 'gg<S-v>G')

-- new tab (use leader to avoid conflict with t til char)
keymap.set('n', '<leader>te', ':tabedit')
keymap.set('n', '<leader>tc', ':tabclose')

-- split window
keymap.set('n', 'ss', ':split<Return><C-w>w')
keymap.set('n', 'sv', ':vsplit<Return><C-w>w')

-- move window
keymap.set('n', '<Space>', '<C-w>w')
keymap.set('n', 'sh', '<C-w>h')
keymap.set('n', 'sj', '<C-w>j')
keymap.set('n', 'sk', '<C-w>k')
keymap.set('n', 'sl', '<C-w>l')

-- resize window
keymap.set('n', '<C-w><left>', '<C-w><')
keymap.set('n', '<C-w><right>', '<C-w>>')
keymap.set('n', '<C-w><up>', '<C-w><+')
keymap.set('n', '<C-w><down>', '<C-w>-')
