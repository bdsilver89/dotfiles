local neogen = require('neogen')

neogen.setup {
  enabled = true,
  snippet_engine = 'luasnip',
}

vim.keymap.set('n', '<leader>ngf', function()
  neogen.generate({type = 'func'})
end)
vim.keymap.set('n', '<leader>ngc', function()
  neogen.generate({type = 'class'})
end)
