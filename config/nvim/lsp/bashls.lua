return {
  cmd = { "bash-language-server", "start" },
  settings = {
    globPattern = vim.env.GLOB_PATTERN or "*@(.sh|.inc|.bash|.command)",
  },
  filetypes = { "bash", "sh" },
}
