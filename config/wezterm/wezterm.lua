local wezterm = require("wezterm")
local act = wezterm.action

local launch_menu = {}
if wezterm.target_triple == "x86_64-pc-windows-msvc" then
	-- cmd.exe
	table.insert(launch_menu, {
		label = "Cmd",
		args = { "cmd.exe", "/NoLogo" },
	})

	-- powershell
	table.insert(launch_menu, {
		label = "PowerShell",
		args = { "powershell.exe", "-NoLogo" },
	})

	-- WSL
	table.insert(launch_menu, {
		label = "WSL",
		args = { "wsl" },
	})

	-- detect VS dev shell
	for _, vsvers in ipairs(wezterm.glob("Microsoft Visual Studio/20*/*", "C:/Program Files")) do
		local version = vsvers:gsub("Microsoft Visual Studio/", ""):gsub("/", " ")
		table.insert(launch_menu, {
			label = "x64 Native Tools VS " .. version,
			args = {
				"cmd.exe",
				"/k",
				"C:/Program Files/" .. vsvers .. "/Common7/Tools/VsDevCmd.bat",
			},
		})
	end
end

wezterm.on("toggle-colorscheme", function(window, pane)
	local overrides = window:get_config_overrides() or {}
	if overrides.color_scheme == "Catppuccin Mocha" then
		overrides.color_scheme = "Catppuccin Latte"
	else
		overrides.color_scheme = "Catppuccin Mocha"
	end
	window:set_config_overrides(overrides)
end)

return {
	animation_fps = 1,
	color_scheme = "Catppuccin Mocha",
	cursor_blink_rate = 500,
	default_cursor_style = "BlinkingBlock",
	hide_tab_bar_if_only_one_tab = true,
	launch_menu = launch_menu,
	default_prog = { "powershell.exe", "-NoLogo" },
	enable_tab_bar = true,
	font_size = 12.0,
	macos_window_background_blur = 0,
	window_background_opacity = 1,
	-- window_decorations = "RESIZE",
	keys = {
		{
			key = "e",
			mods = "CTRL|SHIFT|ALT",
			action = act.EmitEvent("toggle-colorscheme"),
		},
		{
			key = "f",
			mods = "CTRL|SHIFT|ALT",
			action = act.ToggleFullScreen,
		},
		{
			key = "Space",
			mods = "CTRL|SHIFT|ALT",
			action = act.ShowLauncherArgs({ flags = "LAUNCH_MENU_ITEMS|FUZZY" }),
		},
		{
			key = "v",
			mods = "CTRL|SHIFT",
			action = act.PasteFrom("Clipboard"),
		},
		{
			key = "_",
			mods = "CTRL|SHIFT|ALT",
			action = act.SplitVertical({
				domain = "CurrentPaneDomain",
			}),
		},
		{
			key = "|",
			mods = "CTRL|SHIFT|ALT",
			action = act.SplitHorizontal({
				domain = "CurrentPaneDomain",
			}),
		},
	},
}
