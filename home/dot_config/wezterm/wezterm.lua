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
  config.wsl_domains = wezterm.default_wsl_domains()
  if #config.wsl_domains > 0 then
    config.default_domain = config.wsl_domains[1].name
  else
    config.default_prog = { "pwsh.exe", "-NoLogo" }
  end
end

config.keys = {
  { key = "Insert", mods = "SHIFT", action = act.PasteFrom("Clipboard") },
  { key = "Insert", mods = "CTRL", action = act.CopyTo("ClipboardAndPrimarySelection") },
  { key = "Enter", mods = "SHIFT", action = act.SendString("\n") },
  { key = "k", mods = "CTRL|SHIFT", action = act.ClearScrollback("ScrollbackAndViewport") },
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
    config[k] = v
  end
end

return config
