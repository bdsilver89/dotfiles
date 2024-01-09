local wezterm = require("wezterm")
return {
	color_scheme = "Catppuccin Mocha",
	-- color_scheme = "Tokyo Night Moon",
	enable_tab_bar = false,
	font_size = 16.0,
	macos_window_background_blur = 19,
	window_background_opacity = 1.0,
	keys = {
		{
			key = "f",
			mods = "CTRL",
			action = wezterm.action.ToggleFullScreen,
		},
	},
}
