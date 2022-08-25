local keymap = vim.keymap

-- keymap.set('n', 'x', '"_x')

-- Increment/decrement
keymap.set('n', '+', '<C-a>')
keymap.set('n', '-', '<C-x>')

-- Delete a word backwards
-- keymap.set('n', 'dw', 'vb"_d')

-- Select all
keymap.set('n', '<C-a>', 'gg<S-v>G')

-- Save with root permission (not working for now)
--vim.api.nvim_create_user_command('W', 'w !sudo tee > /dev/null %', {})

-- New tab
keymap.set('n', 'te', ':tabedit')
keymap.set('n', 'tc', ':tabclose')

-- Split window
keymap.set('n', 'ss', ':split<Return><C-w>w')
keymap.set('n', 'sv', ':vsplit<Return><C-w>w')

-- Move window
keymap.set('n', '<Space>', '<C-w>w')

-- Move windows with hjkl
keymap.set('', 'sh', '<C-w>h')
keymap.set('', 'sk', '<C-w>k')
keymap.set('', 'sj', '<C-w>j')
keymap.set('', 'sl', '<C-w>l')

-- Move windows with extended arrows
-- keymap.set('', '', '<C-w>h')
-- keymap.set('', '', '<C-w>j')
-- keymap.set('', '', '<C-w>k')
-- keymap.set('', '', '<C-w>l')

-- Resize window with ctrl-arrows
keymap.set('n', '<C-w><C-left>', '<C-w><')
keymap.set('n', '<C-w><C-right>', '<C-w>>')
keymap.set('n', '<C-w><C-up>', '<C-w>+')
keymap.set('n', '<C-w><C-down>', '<C-w>-')
