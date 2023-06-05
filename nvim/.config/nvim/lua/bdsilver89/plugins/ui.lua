return {
  "MunifTanjim/nui.nvim",
  "SmiteshP/nvim-navic",
  {
    "nvim-tree/nvim-web-devicons",
    dependencies = {
      "DaikyXendo/nvim-material-icon",
    },
    config = function()
      require("nvim-web-devicons").setup({
        override = require("nvim-material-icon").get_icons(),
      })
    end,
  },
  {
    "stevearc/dressing.nvim",
    event = "VeryLazy",
    opts = {
      input = { relative = "editor" },
      select = {
        backend = { "telescope", "fzf", "builtin" },
      },
    },
    --    init = function()
    --      vim.ui.select = function(...)
    --        require("lazy").load({ plugins = { "dressing.nvim" } })
    --        return vim.ui.select(...)
    --      end
    --      vim.ui.input = function(...)
    --        require("lazy").load({ plugins = { "dressing.nvim" } })
    --        return vim.ui.input(...)
    --      end
    --    end()
  },
}
