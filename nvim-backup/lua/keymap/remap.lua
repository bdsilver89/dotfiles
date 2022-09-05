local keymap = require('core.keymap')
local nmap, imap, cmap = keymap.nmap, keymap.imap, keymap.cmap
local silent, noremap = keymap.silent, keymap.noremap
local expr = keymap.expr
local opts = keymap.new_opts
local cmd = keymap.cmd

-- noremal remap
nmap({
  -- close buffer
  { '<C-x>k', cmd('bdelete'), opts(noremap, silent) },
  -- save
  { '<C-s>', cmd('write'), opts(noremap) },
  -- yank
  { 'Y', 'y$', opts(noremap) },
  -- buffer jump
  { ']b', cmd('bn'), opts(noremap) },
  { '[b', cmd('bp'), opts(noremap) },
  -- remove trailing white space
  { '<Leader>t', cmd('TrimTrailingWhitespace'), opts(noremap) },
  -- window jump
  { 'sh', '<C-w>h', opts(noremap) },
  { 'sl', '<C-w>l', opts(noremap) },
  { 'sj', '<C-w>j', opts(noremap) },
  { 'sk', '<C-w>k', opts(noremap) },

  -- resize window
  { '<A-[>', cmd('vertical resize -5'), opts(noremap, silent) },
  { '<A-]>', cmd('vertical resize +5'), opts(noremap, silent) },

  -- tabs
  { 'te', cmd('tabedit'), opts(noremap)},
  { 'tc', cmd('tabclose'), opts(noremap)},
  -- split window
  { 'ss', ':split<Return><C-w>w<CR>', opts(noremap) },
  { 'sv', ':vsplit<Return><C-w>w<CR>', opts(noremap) },
  -- { 'se', ':<C-w>=<CR>', opts(noremap) },
  -- move window
  { '<Space>', '<C-w>w', opts(noremap) },
})

-- insertmode remap
imap({
  { '<C-w>', '<C-[>diwa', opts(noremap) },
  { '<C-h>', '<Bs>', opts(noremap) },
  { '<C-d>', '<Del>', opts(noremap) },
  { '<C-u>', '<C-G>u<C-u>', opts(noremap) },
  { '<C-b>', '<Left>', opts(noremap) },
  { '<C-f>', '<Right>', opts(noremap) },
  { '<C-a>', '<Esc>^i', opts(noremap) },
  { '<C-j>', '<Esc>o', opts(noremap) },
  { '<C-k>', '<Esc>O', opts(noremap) },
  { '<C-s>', '<ESC>:w<CR>', opts(noremap) },
  {
    '<C-e>',
    function()
      return vim.fn.pumvisible() == 1 and '<C-e>' or '<End>'
    end,
    opts(expr),
  },
})

-- commandline remap
cmap({
  { '<C-b>', '<Left>', opts(noremap) },
  { '<C-f>', '<Right>', opts(noremap) },
  { '<C-a>', '<Home>', opts(noremap) },
  { '<C-e>', '<End>', opts(noremap) },
  { '<C-d>', '<Del>', opts(noremap) },
  { '<C-h>', '<BS>', opts(noremap) },
})