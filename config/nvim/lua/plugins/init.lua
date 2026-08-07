-- Must precede the subsystems below, which read the merged tables at load time.
require("lang").setup({
  "cmake",
  "cpp",
  "docker",
  "java",
  "json",
  "lua",
  "markdown",
  "python",
  "rust",
  "sql",
  "toml",
  "typescript",
  "xml",
  "yaml",
})

require("plugins.colorscheme")
require("plugins.debugging")
require("plugins.mason")
require("plugins.treesitter")
require("plugins.lsp")
require("plugins.mini")
require("plugins.completion")
require("plugins.git")
require("plugins.diff")
require("plugins.explorer")
require("plugins.fzf")
-- Octo resolves its picker provider at setup, so it must follow fzf.
require("plugins.github")
require("plugins.tmux")
require("plugins.terminal")
require("plugins.formatting")
require("plugins.linting")

require("lang").run_hooks()

vim.cmd.packadd("nvim.undotree")
vim.cmd.packadd("nvim.difftool")
