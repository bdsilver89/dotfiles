require('bufferline').setup({
  options = {
    mode = 'buffers',
    diagnostics = 'nvim_lsp',
    separator_style = 'slant',
    always_show_bufferline = false,
    show_buffer_close_icons = true,
    show_close_icon = true,
    color_icons = true,
    offsets = {
      {
        filetype = 'NvimTree',
        text = 'File Explorer',
        separator = true,
        text_align = 'left',
      },
      -- {
      --   filetype = 'UndoTree',
      --   text = 'Undo',
      --   seperator = true,
      --   text_align = 'right'
      -- }
    },
  },
})

