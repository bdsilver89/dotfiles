return {
  cmd = { "ruff", "server" },
  filetypes = { "python" },
  root_markers = { "pyproject.toml", "ruff.toml", ".ruff.toml", ".git" },
  cmd_env = { RUFF_TRACE = "messages" },
  init_options = {
    settings = {
      logLevel = "error",
    },
  },
  keys = {
    {
      "<leader>co",
      require("utils").lsp.action["source.organizeImports"],
      desc = "Organize Imports",
    },
  },
}
