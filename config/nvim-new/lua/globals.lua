local sysname = vim.uv.os_uname().sysname
local os = sysname:match("Windows") and "Windows" or sysname:match("Linux") and "Linux" or sysname
local is_windows = os == "Windows"

local globals = {
  disable_autoformat = false,
  mapleader = " ",
  maplocalleader = "\\",
  os = os,
  is_windows = is_windows,
  path_delimiter = is_windows and ";" or ":",
  path_separator = is_windows and "\\" or "/",
  ["loaded_node_provider"] = 0,
  ["loaded_python3_provider"] = 0,
  ["loaded_perl_provider"] = 0,
  ["loaded_ruby_provider"] = 0,
}

for name, value in pairs(globals) do
  vim.g[name] = value
end
