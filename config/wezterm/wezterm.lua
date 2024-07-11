local wezterm = require("wezterm")
local act = wezterm.action

return {
	color_scheme = "Catppuccin Mocha",
	-- color_scheme = "Tokyo Night Moon",
	-- color_scheme = "nightfox",
	enable_tab_bar = false,
	font_size = 16.0,
	macos_window_background_blur = 19,
	window_background_opacity = 1.0,
	keys = {
		{
			key = "f",
			mods = "CTRL",
			action = act.ToggleFullScreen,
		},
		-- {
		-- 	key = "v",
		-- 	mods = "CTRL",
		-- 	action = act.PasteFrom("Clipboard"),
		-- },
	},
}
