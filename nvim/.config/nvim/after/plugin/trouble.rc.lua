local status, trouble = pcall(require, "trouble")
if (not status) then return end

local Remap = require('bdsilver89.keymap')
local nnoremap = Remap.nnoremap

trouble.setup {}


nnoremap('<leader>xx', '<cmd>TroubleToggle<cr>', { silent = true})
nnoremap('<leader>xw', '<cmd>TroubleToggle workspace_diagnostics<cr>', { silent = true})
nnoremap('<leader>xd', '<cmd>TroubleToggle document_diagnostics<cr>', { silent = true})
nnoremap('<leader>xq', '<cmd>TroubleToggle quickfix<cr>', { silent = true})
nnoremap('<leader>xl', '<cmd>TroubleToggle loclist<cr>', { silent = true})
nnoremap('gR', '<cmd>TroubleToggle lsp_references<cr>', { silent = true})
