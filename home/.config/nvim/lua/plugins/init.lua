local gh = function(x)
  return "https://github.com/" .. x
end

vim.pack.add({
  { src = gh("projekt0n/github-nvim-theme") },
  { src = gh("nvim-treesitter/nvim-treesitter") },
  { src = gh("nvim-treesitter/nvim-treesitter-textobjects") },
  { src = gh("folke/snacks.nvim") },
  { src = gh("nvim-mini/mini.nvim") },
  { src = gh("saghen/blink.cmp"), version = vim.version.range("^1") },
  { src = gh("nvim-lualine/lualine.nvim") },
  { src = gh("stevearc/conform.nvim") },
  { src = gh("mfussenegger/nvim-lint") },
  { src = gh("mfussenegger/nvim-dap") },
  { src = gh("igorlfs/nvim-dap-view") },
  { src = gh("theHamsta/nvim-dap-virtual-text") },
  { src = gh("lewis6991/gitsigns.nvim") },
  { src = gh("tpope/vim-sleuth") },
  -- { src = gh("tpope/vim-fugitive") },
  -- { src = gh("christoomey/vim-tmux-navigator") },
  { src = gh("meanderingprogrammer/render-markdown.nvim") },
  { src = gh("b0o/SchemaStore.nvim") },
})

vim.cmd.packadd("nvim.undotree")
vim.cmd.packadd("nvim.difftool")

require("plugins.colorscheme")
require("plugins.treesitter")
require("plugins.snacks")
require("plugins.mini")
require("plugins.git")
require("plugins.completion")
require("plugins.lualine")
require("plugins.formatting")
require("plugins.linting")
require("plugins.debugging")
