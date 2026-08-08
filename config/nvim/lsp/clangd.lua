-- clangd needs compile_commands.json at the project root or nothing works.
-- Generate it with -DCMAKE_EXPORT_COMPILE_COMMANDS=ON and symlink it up.
return {
  cmd = {
    "clangd",
    "--background-index",
    "--clang-tidy",
    "--header-insertion=iwyu",
    "--completion-style=detailed",
    "--function-arg-placeholders",
    "--fallback-style=llvm",
  },
  filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
  root_markers = {
    ".clangd", "compile_commands.json", "compile_flags.txt",
    "CMakeLists.txt", "Makefile", ".git",
  },
  init_options = {
    usePlaceholders = true,
    completeUnimported = true,
    clangdFileStatus = true,
  },
}
