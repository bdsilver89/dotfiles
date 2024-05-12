return {
  {
    "nvim-lualine/lualine.nvim",
    enabled = false,
    event = "VeryLazy",
    opts = {
      options = {
        icons_enabled = vim.g.enable_icons,
        component_separators = '|',
        section_separators = '',
      },
      -- sections = {
      --   lualine_x = {
      --     {
      --       require("noice").api.statusline.mode.get,
      --       cond = function() return package.loaded["noice"] and require("noice").api.status.command.has() end,
      --       -- color = { fg = "#ff9e64" },
      --     },
      --     {
      --       require("noice").api.status.command.get,
      --       cond = function() return package.loaded["noice"] and require("noice").api.status.mode.has() end,
      --       -- color = { fg = "#ff9e64" },
      --     },
      --   },
      -- },
    },
  },
}
