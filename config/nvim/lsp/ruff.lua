return {
  cmd = { "ruff", "server" },
  filetypes = { "python" },
  root_markers = { "pyproject.toml", "ruff.toml", ".ruff.toml", ".git" },
  -- Let basedpyright own hover; ruff owns lint + format.
  on_attach = function(client)
    client.server_capabilities.hoverProvider = false
  end,
}
