local status, telescope = pcall(require, 'telescope')
if (not status) then return end

local builtin = require('telescope.builtin')

telescope.setup {
  extensions = {
    file_browser = {
      hijack_netrw = true,
    },
  },
}

telescope.load_extension('fzf')

vim.keymap.set('n', '<leader>?', builtin.oldfiles, { desc = '[?] Find recently opened files' })
vim.keymap.set('n', '<leader><space>', builtin.buffers, { desc = '[ ] Find existing buffers' })
vim.keymap.set('n', '<leader>/', function()
  builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    winblend = 10,
    previewer = false,
  })
end, { desc = '[/] Fuzzily searc in current buffer' })

vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })

-- file browser from current directory
vim.keymap.set('n', '<leader>fb', function()
  telescope.extensions.file_browser.file_browser({
    path = '%:p:h',
    cwd = vim.fn.expand('%:p:h'),
    respect_gitignore = true,
    hidden = true,
    grouped = true,
    initial_mode = 'insert',
  })
end, { desc = "[F]ile [B]rowser" })
