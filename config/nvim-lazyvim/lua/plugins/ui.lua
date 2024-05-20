return {
  {
    "rose-pine/neovim",
    name = "rose-pine",
  },

  -- allow for nerd font icon disable
  {
    "nvim-tree/nvim-web-devicons",
    enabled = vim.g.enable_icons,
  },

  -- lualine statusline
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      -- disable icons in lualine if needed
      opts.options.icons_enabled = vim.g.enable_icons

      -- prefer these separators over defaults
      opts.options.component_separators = "|"
      opts.options.section_separators = ""

      -- add fileencoding
      vim.list_extend(opts.sections.lualine_x, { "encoding" })

      -- add fileformat to track line endings
      vim.list_extend(opts.sections.lualine_x, { "fileformat" })

      return opts
    end,
  },
}
