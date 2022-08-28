local config = {}

function config.zephyr()
	vim.cmd('colorscheme zephyr')
end

function config.galaxyline()
  -- require('modules.ui.eviline')
  require('modules.ui.config.spaceline-rc')
end

function config.dashboard()
  require('modules.ui.config.dashboard-rc')
end

function config.neosolarized()
  require('modules.ui.config.neosolarized-rc')
end

function config.nvim_lualine()
  require('modules.ui.config.lualine-rc')
end

function config.nvim_bufferline()
  require('modules.ui.config.bufferline-rc')
end

function config.nvim_tree()
  require('modules.ui.config.nvimtree-rc')
end

function config.gitsigns()
  require('modules.ui.config.gitsigns-rc')
end

function config.indent_blankline()
  require('modules.ui.config.indent-blankline-rc')
end

function config.colorizer()
  require('colorizer').setup({'*'})
end

function config.trouble()
  require('modules.ui.config.trouble-rc')
end

function config.toggleterm()
  require('modules.ui.config.toggleterm-rc')
end

function config.winbar()
  require('modules.ui.config.winbar-rc')
end

return config
