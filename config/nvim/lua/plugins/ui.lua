return {
  -- support disabling nerd font icons
  {
    "nvim-tree/nvim-web-devicons",
    enabled = vim.g.enable_icons,
  },

  -- lualine statusline
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      -- prefer these separators over defaults
      opts.options.component_separators = "|"
      opts.options.section_separators = ""
      return opts
    end,
  },

  -- bufferline
  {
    "akinsho/bufferline.nvim",
    enabled = false,
  },
}
