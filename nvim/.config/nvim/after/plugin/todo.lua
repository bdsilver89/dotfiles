local status, todo_comments = pcall(require, 'todo-comments')
if (not status) then return end

todo_comments.setup()

vim.keymap.set('n', ']t', function()
  require('todo-comments').jump_next()
end, { desc = 'Jump to next TODO comment' })

vim.keymap.set('n', '[t', function()
  require('todo-comments').jump_prev()
end, { desc = 'Jump to previous TODO comment' })

vim.keymap.set('n', '<leader>tt', '<cmd>TodoTelescope<CR>', { desc = 'TODO Telescope view' })
