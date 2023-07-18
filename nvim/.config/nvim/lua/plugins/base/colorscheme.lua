return {
  {
    "folke/tokyonight.nvim",
    --lazy = false,
    priority = 1000,
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    init = function()
      vim.cmd([[colorscheme catppuccin]])
    end,
  },
  {
    "rose-pine/neovim",
    name = "rose-pine",
    --lazy = false,
    priority = 1000,
  },
  {
    "rebelot/kanagawa.nvim",
    --lazy = false,
    priority = 1000,
  },
  {
    "EdenEast/nightfox.nvim",
    --lazy = false,
    priority = 1000,
  },
  {
    "Everblush/nvim",
    --lazy = false,
    priority = 1000,
  },
}
