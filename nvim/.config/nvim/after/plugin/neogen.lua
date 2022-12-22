local status, neogen = pcall(require, 'neogen')
if (not status) then return end

neogen.setup {
  enabled = true,
  snippet_engine = 'luasnip',
}

vim.keymap.set('n', '<leader>ngf', function()
  neogen.generate({type = 'func'})
end, { desc = '[N]eo[g]en: [F]unction docs' })

vim.keymap.set('n', '<leader>ngc', function()
  neogen.generate({type = 'class'})
end, { desc = '[N]eo[g]en: [C]lass docs' })

