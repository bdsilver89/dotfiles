---@type vim.lsp.Config
return {
  -- zsh is deliberately absent: shellcheck does not lint zsh, so the server
  -- would attach and then report nothing, which is worse than not attaching.
  cmd = { "bash-language-server", "start" },
  filetypes = { "sh", "bash" },
}
