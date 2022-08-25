local package = require('core.pack').package
local conf = require('modules.editor.config')

package({
  'nvim-telescope/telescope.nvim',
  cmd = 'Telescope',
  config = conf.telescope,
  requires = {
    { 'nvim-lua/popup.nvim', opt = true },
    { 'nvim-lua/plenary.nvim', opt = true },
    { 'nvim-telescope/telescope-fzy-native.nvim', opt = true },
    { 'nvim-telescope/telescope-file-browser.nvim', opt = true },
    --{ 'nvim-telescope/telescope-project.nvim', opt = true },
    -- { 'nvim-telescope/telescope-frecency.nvim', opt = true, requires = { 'tami5/sqlite.lua', opt = true} },
  },
})

package({
  'nvim-telescope/telescope-frecency.nvim',
  opt = true,
  after = 'telescope.nvim',
  requires = {
    'tami5/sqlite.lua',
    opt = true,
  }
})

package({
  'nvim-telescope/telescope-project.nvim',
  after = 'telescope-frecency.nvim'
})

package({
  'nvim-treesitter/nvim-treesitter',
  event = 'BufRead',
  run = ':TSUpdate',
  after = 'telescope.nvim',
  config = conf.nvim_treesitter,
})

package({
  'nvim-treesitter/nvim-treesitter-textobjects',
  after = 'nvim-treesitter'
})

package({
  'glepnir/mcc.nvim',
  ft = { 'c', 'cpp', 'go', 'rust' },
  config = conf.mcc_nvim
})

package({
  'kana/vim-operator-replace',
  keys = { { 'x', 'p' } },
  config = function()
    vim.api.nvim_set_keymap('x', 'p', '<Plug>(operator-replace)', { silent = true })
  end,
  requires = 'kana/vim-operator-user',
})

package({
  'rhysd/vim-operator-surround',
  event = 'BufRead',
  requires = 'kana/vim-operator-user'
})

package({
  'antoinemadec/FixCursorHold.nvim',
  event = 'BufReadPre'
})

package({
  'mhartington/formatter.nvim',
  event = 'BufReadPost',
  config = conf.formatter,
})

package({
  'phaazon/hop.nvim',
  event = 'BufReadPost',
  config = conf.hop,
})

package({
  'ahmedkhalf/project.nvim',
  config = conf.project,
})
