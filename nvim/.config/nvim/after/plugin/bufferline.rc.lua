local status, bufferline = pcall(require, "bufferline")
if (not status) then return end

local Remap = require('bdsilver89.keymap')
local nnoremap = Remap.nnoremap

bufferline.setup({
  options = {
    mode = "tabs",
    separator_style = 'slant',
    always_show_bufferline = false,
    show_buffer_close_icons = false,
    show_close_icon = false,
    color_icons = true
  },
  highlights = {
    separator = {
      fg = '#073642',
      bg = '#002b36',
    },
    separator_selected = {
      fg = '#073642',
    },
    background = {
      fg = '#657b83',
      bg = '#002b36'
    },
    buffer_selected = {
      fg = '#fdf6e3',
      bold = true,
    },
    fill = {
      bg = '#073642'
    }
  },
})

-- nnoremap('<Tab>', '<Cmd>BufferLineCycleNext<CR>')
-- nnoremap('<S-Tab>', '<Cmd>BufferLineCyclePrev<CR>')

nnoremap('<Leader>tl', '<Cmd>BufferLineCycleNext<CR>')
nnoremap('<Leader>th', '<Cmd>BufferLineCyclePrev<CR>')

