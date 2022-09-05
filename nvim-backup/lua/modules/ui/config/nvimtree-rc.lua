require('nvim-tree').setup({
  sync_root_with_cwd = true,
  respect_buf_cwd = true,
  update_focused_file = {
    enable = true,
    update_root = true,
  },
  view = {
    width = 30,
    height = 30,
    side = 'left',
    preserve_window_proportions = false,
    number = false,
    relativenumber = false,
    signcolumn = 'yes',
    hide_root_folder = false,
    adaptive_size = true,
    mappings = {
      list = {
        { key = { 'l' }, action = 'edit' },
        { key = { 's' }, action = 'split' },
        { key = { 'v' }, action = 'vsplit' },
        { key = { 'u' }, action = 'dir_up' },
      },
    },
  },
  renderer = {
    icons = {
      glyphs = {
        default = '',
        symlink = '',
        folder = {
          arrow_closed = '',
          arrow_open = '',
          default = '',
          empty = '',
          empty_open = '',
          open = '',
          symlink = '',
          symlink_open = '',
        },
        git = {
          deleted = '',
          ignored = '',
          renamed = '',
          staged = '',
          unmerged = '',
          unstaged = '',
          untracked = 'ﲉ',
        },
      },
    },
  },
})
