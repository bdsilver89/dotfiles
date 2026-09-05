---@type vim.lsp.Config
return {
  cmd = {
    "clangd",
    "--clang-tidy",
    "--header-insertion=iwyu",
    "--completion-style=detailed",
    "--fallback-style=none",
    "--function-arg-placeholders=false",
  },
  filetypes = { "c", "cpp" },
  root_markers = {
  },
  capabilities = {
    textDocument = {
      completion = {
        editsNearCursor = true,
      },
    },
    offsetEncoding = { "utf-8", "utf-16" },
  },
}
