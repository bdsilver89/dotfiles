---@type vim.lsp.Config
return {
  cmd = {
    "clangd",
    "--background-index",
  },
  filetypes = { "c", "cpp" },
  root_markerts = {
    ".clangd",
    "compile_commands.json",
    "compile_flags.txt",
  },
  capabilities = {
    textDocument = {
      completion = {
        editsNearCursor = true,
      },
    },
    offsetEncoding = {
      "utf-8",
      "utf-16",
    },
  },
}
