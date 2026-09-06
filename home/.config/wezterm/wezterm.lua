local wezterm = require("wezterm")
local act = wezterm.action
local config = wezterm.config_builder()

local triple = wezterm.target_triple
local is_windows = triple:find("windows") ~= nil
local is_mac = triple:find("darwin") ~= nil

local function appearance()
	if wezterm.gui then
		return wezterm.gui.get_appearance()
	end
	return "Dark"
end

config.color_scheme = appearance():find("Dark") and "Catppuccin Mocha" or "Catppuccin Latte"

config.font = wezterm.font_with_fallback({
	"JetBrains Mono",
	"Symbols Nerd Font Mono",
})
config.font_size = is_mac and 13.0 or 11.0
config.line_height = 1.05
config.adjust_window_size_when_changing_font_size = false

config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false
config.window_padding = { left = 6, right = 6, top = 4, bottom = 0 }
config.scrollback_lines = 10000
config.audible_bell = "Disabled"
config.window_close_confirmation = "NeverPrompt"
config.check_for_updates = false

if is_windows then
	config.default_prog = { "pwsh.exe", "-NoLogo" }
end

-- Domains -------------------------------------------------------------------
-- WSL: one multiplexer domain per installed distro (WSL:Ubuntu, WSL:Debian, ...).
if is_windows then
	config.wsl_domains = wezterm.default_wsl_domains()
end

-- SSH: one domain per target. Hosts are machine-specific, so they come from an
-- optional `ssh_hosts` table in the `machine` module (loaded below). Each entry:
--   { name = "prod", host = "prod.example.com", user = "brian" }
-- `host` may be an alias from ~/.ssh/config.
local ssh_hosts = {}
do
	local mok, m = pcall(require, "machine")
	if mok and type(m) == "table" and type(m.ssh_hosts) == "table" then
		ssh_hosts = m.ssh_hosts
	end
end

config.ssh_domains = {}
for _, h in ipairs(ssh_hosts) do
	table.insert(config.ssh_domains, {
		name = "SSH:" .. h.name,
		remote_address = h.host,
		username = h.user,
		multiplexing = "None", -- plain ssh; no remote wezterm-mux required
	})
end

-- Launch menu ---------------------------------------------------------------
config.launch_menu = {}

if is_windows then
	table.insert(config.launch_menu, { label = "PowerShell", args = { "pwsh.exe", "-NoLogo" } })
	table.insert(config.launch_menu, { label = "Windows PowerShell", args = { "powershell.exe", "-NoLogo" } })
	table.insert(config.launch_menu, { label = "Command Prompt", args = { "cmd.exe" } })

	for _, dom in ipairs(config.wsl_domains) do
		table.insert(config.launch_menu, {
			label = dom.name, -- e.g. "WSL:Ubuntu"
			domain = { DomainName = dom.name },
		})
	end
end

for _, dom in ipairs(config.ssh_domains) do
	table.insert(config.launch_menu, {
		label = dom.name, -- e.g. "SSH:prod"
		domain = { DomainName = dom.name },
	})
end

config.keys = {
	{ key = "Insert", mods = "SHIFT", action = act.PasteFrom("Clipboard") },
	{ key = "Insert", mods = "CTRL", action = act.CopyTo("ClipboardAndPrimarySelection") },
	{ key = "Enter", mods = "SHIFT", action = act.SendString("\n") },
	{ key = "k", mods = "CTRL|SHIFT", action = act.ClearScrollback("ScrollbackAndViewport") },
	-- Launcher filtered to the entries built above (plus domains/tabs).
	{
		key = "l",
		mods = "CTRL|SHIFT",
		action = act.ShowLauncherArgs({ flags = "FUZZY|LAUNCH_MENU_ITEMS|DOMAINS" }),
	},
}

config.mouse_bindings = {
	{
		event = { Up = { streak = 1, button = "Left" } },
		mods = "NONE",
		action = act.CompleteSelection("ClipboardAndPrimarySelection"),
	},
	{
		event = { Up = { streak = 2, button = "Left" } },
		mods = "NONE",
		action = act.CompleteSelection("ClipboardAndPrimarySelection"),
	},
	{
		event = { Up = { streak = 3, button = "Left" } },
		mods = "NONE",
		action = act.CompleteSelection("ClipboardAndPrimarySelection"),
	},
	{
		event = { Down = { streak = 1, button = "Right" } },
		mods = "NONE",
		action = act.PasteFrom("Clipboard"),
	},
	{
		event = { Up = { streak = 1, button = "Left" } },
		mods = "CTRL",
		action = act.OpenLinkAtMouseCursor,
	},
}

local ok, machine = pcall(require, "machine")
if ok and type(machine) == "table" then
	for k, v in pairs(machine) do
		if k ~= "ssh_hosts" then -- consumed above for ssh_domains, not a config key
			config[k] = v
		end
	end
end

return config
