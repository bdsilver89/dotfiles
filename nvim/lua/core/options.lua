local global = require("core.global")

local function load_options()
	local global_local = {
		encoding = "utf-8",
		fileencoding = "utf-8",
		number = true,
		title = true,
		autoindent = true,
		smartindent = true,
		hlsearch = true,
		backup = false,
		showcmd = true,
		cmdheight = 1,
		laststatus = 2,
		expandtab = true,
		scrolloff = 10,
		shell = 'zsh',
		backupskip = { '/tmp/*', '/private/tmp/*' },
		inccommand = 'split',
		ignorecase = true, -- Case insensitive searching UNLESS /C or capital in search
		smarttab = true,
		breakindent = true,
		shiftwidth = 2,
		tabstop = 2,
		wrap = false, -- No Wrap lines
		backspace = { 'start', 'eol', 'indent' },
		-- path:append { '**' } -- Finding files - Search down into subfolders
		-- wildignore:append { '*/node_modules/*' }
		cursorline = true,
		termguicolors = true,
		winblend = 0,
		wildoptions = 'pum',
		pumblend = 5,
		background = 'dark'
	}

	for name, value in pairs(global_local) do
		vim.opt[name] = value
	end
end

load_options()
