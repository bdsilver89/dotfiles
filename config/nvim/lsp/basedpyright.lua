-- Type checking only; linting and formatting go to ruff (see lsp/ruff.lua).
return {
  cmd = { "basedpyright-langserver", "--stdio" },
  filetypes = { "python" },
  root_markers = { "pyproject.toml", "uv.lock", "setup.py", ".git" },
  settings = {
    basedpyright = {
      analysis = {
        typeCheckingMode = "standard",
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        diagnosticSeverityOverrides = { reportUnusedImport = "none" },
      },
    },
  },
}
