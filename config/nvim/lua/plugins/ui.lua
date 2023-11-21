return {
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      opts.options.component_separators = "|"
      opts.options.section_separators = ""
      return opts
    end,
  },
  {
    "folke/zen-mode.nvim",
    cmd = "ZenMode",
    keys = {
      { "<leader>zz", "<cmd>ZenMode<cr>", desc = "Zen Mode" },
    },
    opts = {
      plugins = {
        gitsigns = true,
        tmux = true,
      },
    },
  },
  {
    "folke/edgy.nvim",
    opts = function(_, opts)
      opts.keys = {}
      return opts
    end,
  },
  {
    "NvChad/nvim-colorizer.lua",
    event = "LazyFile",
    -- TODO: Attach and detach
    -- require("colorizer").attach_to_buffer(0, { mode = "background", css = true})
    -- require("colorizer").detach_from_buffer(0, { mode = "virtualtext", css = true})
    config = true,
  },
}
