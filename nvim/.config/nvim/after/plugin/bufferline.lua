local status, bufferline = pcall(require, 'bufferline')
if (not status) then return end

bufferline.setup {}

vim.keymap.set('n', '[b', '<cmd>BufferLineCycleNext<CR>', { desc = 'Bufferline cycle next' })
vim.keymap.set('n', ']b', '<cmd>BufferLineCyclePrev<CR>', { desc = 'Bufferline cycle prev' })
vim.keymap.set('n', 'be', '<cmd>BufferLineSortByExtension<CR>', { desc = 'Bufferline sort by extension' })
vim.keymap.set('n', 'bd', '<cmd>BufferLineSortByDirectory<CR>', { desc = 'Bufferline sort by directory' })
