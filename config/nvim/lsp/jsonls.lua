return {
  cmd = { "vscode-json-language-server", "--stdio" },
  filetypes = { "json", "jsonc" },
  root_markers = { ".git" },
  init_options = { provideFormatter = false },  -- prettier handles it
  settings = {
    json = { validate = { enable = true } },
  },
}
