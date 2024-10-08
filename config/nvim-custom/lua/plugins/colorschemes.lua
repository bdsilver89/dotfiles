return {
  {
    "catppuccin/nvim",
    lazy = true,
    priority = 1000,
    enabled = true,
    name = "catppuccin",
    init = function()
      vim.cmd.colorscheme("catppuccin")
    end,
    opts = {
      integrations = {
        cmp = true,
        gitsigns = true,
        headlines = true,
        illuminate = true,
        indent_blankline = { enabled = true },
        lsp_trouble = true,
        mason = true,
        markdown = true,
        mini = true,
        native_lsp = {
          enabled = true,
          underlines = {
            errors = { "undercurl" },
            hints = { "undercurl" },
            warnings = { "undercurl" },
            information = { "undercurl" },
          },
        },
        neotest = true,
        neotree = true,
        noice = true,
        notify = true,
        overseer = true,
        semantic_tokens = true,
        telescope = true,
        treesitter = true,
        treesitter_context = true,
        which_key = true,
      },
    },
  },

  {
    "rose-pine/neovim",
    name = "rose-pine",
    lazy = true,
    priority = 1000,
    enabled = false,
    opts = {},
    init = function()
      vim.cmd.colorscheme("rose-pine")
    end,
  },

  {
    "folke/tokyonight.nvim",
    priority = 1000,
    lazy = true,
    enabled = false,
    init = function()
      vim.cmd.colorscheme("tokyonight-night")
    end,
  },
}
