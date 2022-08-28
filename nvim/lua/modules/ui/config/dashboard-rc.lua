local home = os.getenv('HOME')
local db = require('dashboard')
local z = require('zephyr')

db.session_directory = home .. '/.cache/nvim/session'
-- db.preview_command = 'cat | lolcat -F 0.3'
-- db.preview_file_path = home .. '/.config/nvim/static/neovim.cat'
db.preview_file_height = 12
db.preview_file_width = 80
db.custom_center = {
  {
    icon = '  ',
    icon_hl = { fg = z.red },
    desc = 'Update Plugins                          ',
    shortcut = 'SPC p u',
    action = 'PackerUpdate',
  },
  {
    icon = '  ',
    icon_hl = { fg = z.red },
    desc = 'Find Project                            ',
    shortcut = 'SPC f p',
    action = 'Telescope project',
  },
  {
    icon = '  ',
    icon_hl = { fg = z.red },
    desc = 'File Frecency                           ',
    shortcut = 'SPC f r',
    action = 'Telescope frecency',
  },
  {
    icon = '  ',
    icon_hl = { fg = z.yellow },
    desc = 'Recently opened files                   ',
    action = 'Telescope oldfiles',
    shortcut = 'SPC f h',
  },
  {
    icon = '  ',
    icon_hl = { fg = z.cyan },
    desc = 'Find  File                              ',
    action = 'Telescope find_files find_command=rg,--hidden,--files',
    shortcut = 'SPC f f',
  },
  {
    icon = '  ',
    icon_hl = { fg = z.blue },
    desc = 'File Browser                            ',
    action = 'Telescope file_browser',
    shortcut = 'SPC f b',
  },
  {
    icon = '  ',
    icon_hl = { fg = z.oragne },
    desc = 'Find  word                              ',
    action = 'Telescope live_grep',
    shortcut = 'SPC f b',
  },
  {
    icon = '  ',
    icon_hl = { fg = z.redwine },
    desc = 'Open Personal dotfiles                  ',
    action = 'Telescope dotfiles path=' .. home .. '/.dotfiles',
    shortcut = 'SPC f d',
  },
}
