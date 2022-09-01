local package = require('core.pack').package
local conf = require('modules.editor.config')

package({
  'nvim-lua/plenary.nvim',
  opt = false,
})

package({
  'nvim-telescope/telescope.nvim',
  cmd = 'Telescope',
  config = conf.telescope,
  requires = {
    { 'nvim-lua/popup.nvim', opt = true },
    { 'nvim-lua/plenary.nvim', opt = true },
    { 'nvim-telescope/telescope-fzf-native.nvim', opt = true, run = "make" },
    { 'nvim-telescope/telescope-file-browser.nvim', opt = true },
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
  'nvim-telescope/telescope-dap.nvim',
  after = 'telescope-frecency.nvim',
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

-- package({
--   'glepnir/mcc.nvim',
--   ft = { 'c', 'cpp', 'go', 'rust' },
--   config = conf.mcc_nvim
-- })
--
-- package({
--   'kana/vim-operator-replace',
--   keys = { { 'x', 'p' } },
--   config = function()
--     vim.api.nvim_set_keymap('x', 'p', '<Plug>(operator-replace)', { silent = true })
--   end,
--   requires = 'kana/vim-operator-user',
-- })
--
-- package({
--   'rhysd/vim-operator-surround',
--   event = 'BufRead',
--   requires = 'kana/vim-operator-user'
-- })
--
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
  'terrortylor/nvim-comment',
  event = 'BufReadPost',
  config = conf.nvim_comment,
})

package({
  'mfussenegger/nvim-dap',
  config = conf.nvim_dap,
  module = 'dap',
  cmd = {
    'DapSetLogLevel',
    'DapShowLog',
    'DapContinue',
    'DapToggleBreakpoint',
    'DapToggleRepl',
    'DapStepOver',
    'DapStepInto',
    'DapStepOut',
    'DapTerminate',
  },
})

package({
  'rcarriga/nvim-dap-ui',
  config = conf.nvim_dap_ui,
  requires = {
    'mfussenegger/nvim-dap',
  },
})

-- package({
--   'theHamsta/nvim-dap-virtual-text',
--   config = conf.nvim_dap_virtual_text,
-- })

-- package({
--   'Pocco81/dap-buddy.nvim',
--   config = conf.dap_buddy,
-- })

package({
  'nvim-neotest/neotest',
  config = conf.neotest,
  requires = {
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter',
    'autoinemadec/FixCursorHold.nvim',
    'nvim-neotest/neotest-plenary',
  },
})

package({
  'romainl/vim-cool',
  event = { "CursorMoved", "InsertEnter" }
})

package({
  'luukvbaal/stabilize.nvim',
  event = "BufReadPost",
})
