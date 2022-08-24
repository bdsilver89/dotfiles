local ui = {}
local conf = require("modules.ui.config")

ui["svrana/neosolarized.nvim"] = {
	opt = false,
	requires = {
		"tjdevries/colorbuddy.nvim",
		opt = false,
	},
	config = conf.neosolarized,
}
ui["goolord/alpha-nvim"] = {
	opt = true,
	event = "BufWinEnter",
	config = conf.alpha,
}
ui["kyazdani42/nvim-web-devicons"] = { opt = false }
ui["rcarriga/nvim-notify"] = {
	opt = false,
	config = conf.notify,
}
ui["lukas-reineke/indent-blankline.nvim"] = {
	opt = true,
	event = "BufReadPost",
	config = conf.indent_blankline,
}
ui["akinsho/bufferline.nvim"] = {
	opt = true,
	tag = "*",
	event = "BufReadPost",
	config = conf.nvim_bufferline,
}
ui["hoob3rt/lualine.nvim"] = {
	opt = false,
	config = conf.lualine,
}
ui["lewis6991/gitsigns.nvim"] = {
	opt = true,
	event = { "BufReadPost", "BufNewFile" },
	config = conf.gitsigns,
	requires = { "nvim-lua/plenary.nvim", opt = true },
}
ui["mbbill/undotree"] = {
	opt = true,
	cmd = "UndotreeToggle",
}
ui["SmiteshP/nvim-navic"] = {
	opt = true,
	after = "nvim-lspconfig",
	config = conf.nvim_navic,
}
ui["kyazdani42/nvim-tree.lua"] = {
	opt = true,
	cmd = { "NvimTreeToggle" },
	config = conf.nvim_tree,
}
ui["dstein64/nvim-scrollview"] = {
	opt = true,
	event = { "BufReadPost" },
	config = conf.scrollview,
}
ui["j-hui/fidget.nvim"] = {
	opt = true,
	event = "BufReadPost",
	config = conf.fidget,
}

return ui