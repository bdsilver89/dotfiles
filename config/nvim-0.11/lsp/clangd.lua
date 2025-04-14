return {
  cmd = {
    "clangd",
    "--background-index",
    "--clang-tidy",
    "--header-insertion=iwyu",
    "--completion-stye=detailed",
    "--function-arg-placeholders",
    "--fallback-style=none",
  },
  filetypes = { "c", "cpp" },
  root_markers = { ".clangd", "compile_commands.json", "compile_flags.txt" },
  capabilities = {
    textDocument = {
      completion = {
        editsNearCursor = true,
      },
    },
    offsetEncoding = { "utf-8", "utf-16" },
  },
}
