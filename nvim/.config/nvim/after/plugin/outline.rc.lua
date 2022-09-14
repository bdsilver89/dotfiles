local status, outline = pcall(require, 'symbols-outline')
if (not status) then return end

local nnoremap = require('bdsilver89.keymap').nnoremap

outline.setup({
  highlight_hovered_item = true,
  show_guides = true,
})

nnoremap('<leader>so', '<Cmd>SymbolsOutline<CR>')
