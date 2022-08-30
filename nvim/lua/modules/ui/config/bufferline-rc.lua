require('bufferline').setup({
  options = {
    mode = 'tabs',
    diagnostics = 'nvim_lsp',
    separator_style = 'slant',
    always_show_bufferline = false,
    show_buffer_close_icons = true,
    show_close_icon = true,
    color_icons = true,
    max_name_length = 14,
    max_prefix_length = 13,
    tab_size = 20,
    offsets = {
      {
        filetype = 'NvimTree',
        text = 'File Explorer',
        text_align = 'center',
        padding = 1
      }
    },
  },
})

