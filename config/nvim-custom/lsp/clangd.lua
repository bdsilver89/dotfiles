return {
  cmd = { "clangd", "--background-index" },
  root_markers = { ".clangd", "compile_commands.json", "compile_flags.txt" },
  filetypes = { "c", "cpp" },
  capabilities = {
    textDocument = {
      completion = {
        editsNearCursor = true,
      },
    },
    offsetEncoding = { "utf-8", "utf-16" },
  },
}
