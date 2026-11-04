---@type vim.lsp.Config
return {
  cmd = { "neocmakelsp", "stdio" },
  filetypes = { "cmake" },
  root_markers = { "CMakePresets.json", "CMakeLists.txt", ".git" },
}
