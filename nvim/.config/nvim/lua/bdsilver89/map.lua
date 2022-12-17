vim.keymap.set('n', 'x', '"_x')

-- paste from yank register without deleting from yank register
vim.keymap.set('x', '<leader>p', [["_dP]])
vim.keymap.set({'n','v'}, '<leader>y', [["+y]])
vim.keymap.set('n', '<leader>Y', [["+Y]])
vim.keymap.set({'n','v'}, '<leader>d', [["_d]])

vim.keymap.set('n', "Y", "yg$")
vim.keymap.set('n', "n", "nzzzv")
vim.keymap.set('n', "N", "Nzzzv")
vim.keymap.set('n', "J", "mzJ`z")
vim.keymap.set('n', "<C-d>", "<C-d>zz")
vim.keymap.set('n', "<C-u>", "<C-u>zz")

vim.keymap.set('n', '<leader>f', vim.lsp.buf.format)

vim.keymap.set('n', 'Q', '<nop>')

-- move
vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv")
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv")

-- increment/decrement
vim.keymap.set('n', '+', '<C-a>')
vim.keymap.set('n', '-', '<C-x>')
vim.keymap.set('x', '+', '<C-a>')
vim.keymap.set('x', '-', '<C-x>')

-- select all
vim.keymap.set('n', '<C-a>', 'gg<S-v>G')

-- new tab (use leader to avoid conflict with t til char)
vim.keymap.set('n', '<leader>te', ':tabedit')
vim.keymap.set('n', '<leader>tc', ':tabclose')

vim.keymap.set('n', '<C-k>', '<cmd>cnext<CR>zz')
vim.keymap.set('n', '<C-j>', '<cmd>cprev<CR>zz')
vim.keymap.set('n', '<leader>k', '<cmd>lnext<CR>zz')
vim.keymap.set('n', '<leader>j', '<cmd>lprev<CR>zz')

vim.keymap.set('n', '<leader>x', '<cmd>!chmod +x %<CR>', { silent = true })

-- split window
vim.keymap.set('n', 'ss', ':split<Return><C-w>w')
vim.keymap.set('n', 'sv', ':vsplit<Return><C-w>w')

-- move window
-- vim.keymap.set('n', '<Space>', '<C-w>w') -- wow this is slow
vim.keymap.set('n', 'sh', '<C-w>h')
vim.keymap.set('n', 'sj', '<C-w>j')
vim.keymap.set('n', 'sk', '<C-w>k')
vim.keymap.set('n', 'sl', '<C-w>l')

-- resize window
vim.keymap.set('n', '<C-w><left>', '<C-w><')
vim.keymap.set('n', '<C-w><right>', '<C-w>>')
vim.keymap.set('n', '<C-w><up>', '<C-w>+')
vim.keymap.set('n', '<C-w><down>', '<C-w>-')
