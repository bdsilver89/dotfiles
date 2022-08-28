require('bufferline').setup({
  options = {
    mode = 'buffers',
    diagnostics = 'nvim_lsp',
    seperator_style = 'slant',
    always_show_bufferline = false,
    show_buffer_close_icons = false,
    show_close_icon = false,
    color_icons = true,
    offsets = {
      {
        filetype = 'NvimTree',
        text = 'File Explorer',
        highlight = 'Directory',
        separator = true,
        text_align = 'left',
      },
      -- {
      --   filetype = 'UndoTree',
      --   text = 'Undo',
      --   highlight = 'Directory',
      --   seperator = true,
      -- }
    },
  },
})

