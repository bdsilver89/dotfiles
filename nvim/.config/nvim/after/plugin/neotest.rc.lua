local status, neotest = pcall(require, 'neotest')
if (not status) then return end

neotest.setup({
  adapters = {
    -- require('neotest-go')({}),
    -- require('neotest-python')({}),
    require('neotest-rust')
  }
})


-- run nearest test
vim.keymap.set('n', 'tt', function() neotest.run.run() end, { noremap = true })

-- run whole file
vim.keymap.set('n', 'tf', function() neotest.run.run(vim.fn.expand('%')) end, { noremap = true })

-- debug nearest test
vim.keymap.set('n', 'td', function() neotest.run.run({ strategy = 'dap' }) end, { noremap = true })

