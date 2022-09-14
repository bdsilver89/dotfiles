local Remap = require('bdsilver89.keymap')
local nnoremap = Remap.nnoremap
local vnoremap = Remap.vnoremap
-- local inoremap = Remap.inoremap
local xnoremap = Remap.xnoremap
-- local nmap = Remap.nmap

nnoremap('x', '"_x')

-- paste from yank register without deleting from yank register
xnoremap('<leader>p', "\"_dP")

nnoremap("Y", "yg$")
nnoremap("n", "nzzzv")
nnoremap("N", "Nzzzv")
nnoremap("J", "mzJ`z")
nnoremap("<C-d>", "<C-d>zz")
nnoremap("<C-u>", "<C-u>zz")

-- move
vnoremap('J', ":m '>+1<CR>gv=gv")
vnoremap('K', ":m '<-2<CR>gv=gv")

-- increment/decrement
nnoremap('+', '<C-a>')
nnoremap('-', '<C-x>')
xnoremap('+', '<C-a>')
xnoremap('-', '<C-x>')

-- select all
nnoremap('<C-a>', 'gg<S-v>G')

-- new tab (use leader to avoid conflict with t til char)
nnoremap('<leader>te', ':tabedit')
nnoremap('<leader>tc', ':tabclose')

-- split window
nnoremap('ss', ':split<Return><C-w>w')
nnoremap('sv', ':vsplit<Return><C-w>w')

-- move window
-- nnoremap('<Space>', '<C-w>w') -- wow this is slow
nnoremap('sh', '<C-w>h')
nnoremap('sj', '<C-w>j')
nnoremap('sk', '<C-w>k')
nnoremap('sl', '<C-w>l')

-- resize window
nnoremap('<C-w><left>', '<C-w><')
nnoremap('<C-w><right>', '<C-w>>')
nnoremap('<C-w><up>', '<C-w>+')
nnoremap('<C-w><down>', '<C-w>-')
