local keymap = vim.keymap

keymap.set('n', 'x', '"_x')

-- increment and decrement
keymap.set('n', '+', '<C-a>')
keymap.set('n', '-', '<C-x>')

-- tab
keymap.set('n', 'te', ':tabedit')
keymap.set('n', 'tc', ':tabclose')

-- split
keymap.set('n', 'ss', ':split<Return><C-w>w')
keymap.set('n', 'sv', ':vsplit<Return><C-w>w')

-- move window
keymap.set('n', '<Space>', '<C-w>w')
keymap.set('', 'sh', '<C-w>h')
keymap.set('', 'sk', '<C-w>k')
keymap.set('', 'sj', '<C-w>j')
keymap.set('', 'sl', '<C-w>l')

-- resize window
keymap.set('n', '<C-w><left>', '<C-w><')
keymap.set('n', '<C-w><right>', '<C-w>>')
keymap.set('n', '<C-w><up>', '<C-w>+')
keymap.set('n', '<C-w><down>', '<C-w>-')
