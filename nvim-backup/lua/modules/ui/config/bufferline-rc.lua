require('bufferline').setup({
  options = {
    mode = 'tabs',
    diagnostics = 'nvim_lsp',
    separator_style = 'slant',
    number = nil,
    -- modified_icon = "✥",
    -- buffer_close_icon = "",
    -- left_trunc_marker = "",
    -- right_trunc_marker = "",
    always_show_bufferline = false,
    show_buffer_close_icons = true,
    show_close_icon = true,
    show_tab_indicators = true,
    color_icons = true,
    max_name_length = 14,
    max_prefix_length = 13,
    tab_size = 20,
    offsets = {
      {
        filetype = 'NvimTree',
        text = 'File Explorer',
        text_align = 'center',
        separator = true,
        padding = 1,
      }
    },
  },
})

