return {
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

  -- filename
  {
    "b0o/incline.nvim",
    event = "LazyFile",
    config = true,
  },

  -- bufferline, change to tab mode
  {
    "akinsho/bufferline.nvim",
    enabled = false,
    -- opts = {
    --   options = {
    --     mode = "tabs",
    --   },
    -- },
  },
}
