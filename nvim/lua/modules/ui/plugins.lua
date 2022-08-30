local package = require('core.pack').package
local conf = require('modules.ui.config')

package({
	'glepnir/dashboard-nvim',
	config = conf.dashboard,
})

package({
	'glepnir/zephyr-nvim',
	config = conf.zephyr,
})

package({
	'glepnir/galaxyline.nvim',
	config = conf.galaxyline,
	requires = {
		'kyazdani42/nvim-web-devicons',
	},
})

-- package({
-- 	'svrana/neosolarized.nvim',
--     requires = { 'tjdevries/colorbuddy.nvim' },
-- 	config = conf.neosolarized,
-- })

-- package({
-- 	'nvim-lualine/lualine.nvim',
-- 	config = conf.nvim_lualine,
-- })

package({
	'akinsho/nvim-bufferline.lua',
	config = conf.nvim_bufferline,
})

package({
	'lukas-reineke/indent-blankline.nvim',
	event = 'BufRead',
	config = conf.indent_blankline,
})

package({
	'kyazdani42/nvim-tree.lua',
	cmd = 'NvimTreeToggle',
	config = conf.nvim_tree,
	requires = {
		'kyazdani42/nvim-web-devicons',
	},
})

package({
	'lewis6991/gitsigns.nvim',
	event = {
		'BufRead',
		'BufNewFile',
	},
	config = conf.gitsigns,
	requires = {
		'nvim-lua/plenary.nvim',
		opt = true,
	}
})

package({
  'mbbill/undotree',
  cmd = 'UndotreeToggle',
})

package({
	'norcalli/nvim-colorizer.lua',
  event = "BufReadPost",
	config = conf.colorizer
})

package({
  'folke/trouble.nvim',
  cmd = { 'Trouble', 'TroubleToggle', 'TroubleRefresh' },
  event = "BufReadPost",
  config = conf.trouble,
})

package({
	'akinsho/toggleterm.nvim',
  event = 'UIEnter',
	config = conf.toggleterm,
})

-- package({
--   'preservim/tagbar',
-- })

package({
  'SmiteshP/nvim-navic',
  config = conf.nvim_navic,
})

package({
  'rcarriga/nvim-notify',
  config = conf.notify,
})

-- Uncomment for > Neovim 0.8
package({
  'fgheng/winbar.nvim',
  config = conf.winbar,
  requires = {
    'SmiteshP/nvim-navic',
    'kyazdani42/nvim-web-devicons',
  },
})

