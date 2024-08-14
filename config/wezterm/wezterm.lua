local wezterm = require("wezterm")
local act = wezterm.action

return {
	color_scheme = "Catppuccin Mocha",
	enable_tab_bar = false,
	font_size = 16.0,
	macos_window_background_blur = 0,
	window_background_opacity = 1,
	window_decorations = "RESIZE",
	keys = {
		{
			key = "f",
			mods = "CTRL|SHIFT",
			action = act.ToggleFullScreen,
		},
		{
			key = "v",
			mods = "CTRL|SHIFT",
			action = act.PasteFrom("Clipboard"),
		},
	},
}
