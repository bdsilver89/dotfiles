vim.api.nvim_create_autocmd("PackChanged", {
  callback = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    if kind ~= "install" and kind ~= "update" then return end
    if name == "telescope-fzf-native.nvim" and vim.fn.executable("make") == 1 then
      vim.system({ "make" }, { cwd = ev.data.path }):wait()
    elseif name == "nvim-treesitter" then
      vim.cmd("TSUpdate")
    end
  end,
})

vim.pack.add({
  { src = "https://github.com/catppuccin/nvim", name = "catppuccin" },
  "https://github.com/lewis6991/gitsigns.nvim",
  "https://github.com/mason-org/mason.nvim",
  "https://github.com/neovim/nvim-lspconfig",
  "https://github.com/nvim-lualine/lualine.nvim",
  "https://github.com/nvim-lua/plenary.nvim",
  "https://github.com/nvim-mini/mini.nvim",
  "https://github.com/nvim-treesitter/nvim-treesitter",
  "https://github.com/nvim-telescope/telescope.nvim",
  "https://github.com/nvim-telescope/telescope-fzf-native.nvim",
  "https://github.com/nvim-telescope/telescope-ui-select.nvim",
  "https://github.com/nvim-telescope/telescope-frecency.nvim",
  "https://github.com/tpope/vim-dispatch",
  "https://github.com/tpope/vim-fugitive",
  "https://github.com/tpope/vim-sleuth",
  "https://github.com/christoomey/vim-tmux-navigator",
})

require("plugins.colorscheme")
require("plugins.mason")
require("plugins.git")
require("plugins.lsp")
require("plugins.statusline")
require("plugins.mini")
require("plugins.telescope")
require("plugins.treesitter")
