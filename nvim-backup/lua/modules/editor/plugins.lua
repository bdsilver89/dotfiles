local editor = {}
local conf = require("modules.editor.config")

editor["nvim-treesitter/nvim-treesitter"] = {
	opt = true,
	run = ":TSUpdate",
	event = "BufReadPost",
	config = conf.nvim_treesitter,
}

editor["folke/zen-mode.nvim"] = {
  opt = true,
	event = "BufReadPost",
  config = conf.zen_mode,
}
editor["terrortylor/nvim-comment"] = {
	opt = false,
	config = conf.nvim_comment,
}
editor["norcalli/nvim-colorizer.lua"] = {
	opt = true,
	event = "BufReadPost",
	config = conf.nvim_colorizer,
}
editor["akinsho/toggleterm.nvim"] = {
	opt = true,
	event = "UIEnter",
	config = conf.toggleterm,
}
editor["phaazon/hop.nvim"] = {
  opt = true,
  branch = "v2",
  event = "BufReadPost",
  config = conf.hop,
}
-- editor["rainbowhxch/accelerated-jk.nvim"] = {
--   opt = true,
--   event = "BufWinEnter",
--   config = conf.accelerated_jk,
-- }

return editor
