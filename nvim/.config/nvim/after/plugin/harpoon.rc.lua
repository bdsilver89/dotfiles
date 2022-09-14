local status, _ = pcall(require, 'harpoon')
if (not status) then return end

local Remap = require('bdsilver89.keymap')
local nnoremap = Remap.nnoremap

local silent = { silent = true }

local harpoon_mark = require('harpoon.mark')
local harpoon_ui = require('harpoon.ui')
-- local harpoon_cmd_ui = require('harpoon.cmd-ui')
-- local harpoon_tmux = require('harpoon.tmux')
-- local harpoon_term = require('harpoon.term')

-- windows
nnoremap('<leader>m', function() harpoon_mark.add_file() end, silent)
nnoremap('<leader>h', function() harpoon_ui.toggle_quick_menu() end, silent)

nnoremap('<leader>n', function() harpoon_ui.nav_file(1) end, silent)
nnoremap('<leader>e', function() harpoon_ui.nav_file(2) end, silent)
nnoremap('<leader>i', function() harpoon_ui.nav_file(3) end, silent)
nnoremap('<leader>o', function() harpoon_ui.nav_file(4) end, silent)

-- commands and.tmuxinals
-- nnoremap('<leader>M', function() harpoon_cmd_ui.toggle_quick_menu() end, silent)

-- nnoremap('<leader>t', function() harpoon_tmux.gotoTerminal(1) end, silent)
-- nnoremap('<leader>s', function() harpoon_tmux.gotoTerminal(2) end, silent)
-- nnoremap('<leader>r', function() harpoon_tmux.gotoTerminal(3) end, silent)
-- nnoremap('<leader>a', function() harpoon_tmux.gotoTerminal(4) end, silent)

-- nnoremap('<leader>t', function() harpoon_term.gotoTerminal(1) end, silent)
-- nnoremap('<leader>s', function() harpoon_term.gotoTerminal(2) end, silent)
-- nnoremap('<leader>r', function() harpoon_term.gotoTerminal(3) end, silent)
-- nnoremap('<leader>a', function() harpoon_term.gotoTerminal(4) end, silent)

local group = vim.api.nvim_create_augroup('harpoon', { clear = true })

-- splits from harpoon
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'harpoon',
  group = group,
  callback = function()
    local opts = { silent = true, buffer = false }
    nnoremap('hsv', function()
      local curline = vim.api.nvim_get_current_line()
      local working_dir = vim.fn.getcwd() .. '/'
      vim.cmd('vs')
      vim.cmd('e' .. working_dir .. curline)
    end, opts)
  end,
})
