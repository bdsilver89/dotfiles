return {
  cmd = { "ruff", "server" },
  filetypes = { "python" },
  root_markers = { "pyproject.toml", "ruff.toml", ".ruff.toml", ".git" },
  on_attach = function(client)
    -- Pyright supplies hover/type information; Ruff handles lint and formatting.
    client.server_capabilities.hoverProvider = false
  end,
}
