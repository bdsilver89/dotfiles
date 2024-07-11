return {
  {
    "nvim-tree/nvim-web-devicons",
    enabled = vim.g.enable_icons,
    lazy = true
  },

  {
    "MunifTanjim/nui.nvim",
    lazy = true
  },

  {
    "rcarriga/nvim-notify",
    event = "VeryLazy",
    keys = {
      {
        "<leader>un",
        function()
          require("notify").dismiss({ silent = true, pending = true })
        end,
        desc = "Dismiss all notifications",
      },
    },
    opts = {
      stages = "static",
      timeout = 3000,
      max_height = function()
        return math.floor(vim.o.lines * 0.75)
      end,
      max_width = function()
        return math.floor(vim.o.columns * 0.75)
      end,
      on_open = function(win)
        vim.api.nvim_win_set_config(win, { zindex = 100 })
      end,
    },
    config = function(_, opts)
      require("notify").setup(opts)
      vim.notify = require("notify")
    end,
  },

  {
    "stevearc/dressing.nvim",
    lazy = true,
    init = function()
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.select = function(...)
        require("lazy").load({ plugins = { "dressing.nvim" } })
        return vim.ui.select(...)
      end
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.input = function(...)
        require("lazy").load({ plugins = { "dressing.nvim" } })
        return vim.ui.input(...)
      end
    end,
  },

  {
    "nvimdev/dashboard-nvim",
    event = "VimEnter",
    config = function()
      local logo = [[
        ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
        ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
        ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
        ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
        ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
        ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
      ]]

      require("dashboard").setup({
        theme = "hyper",
        hide = {
          statusline = true,
          tabline = true,
          winbar = true,
        },
        config = {
          header = vim.split(logo, "\n"),
          project = { enable = true },
          disable_move = true,
          shortcut = {
            {
              desc = 'Update',
              icon = ' ',
              group = 'Include',
              action = function()
                vim.schedule(function() vim.cmd("Lazy update") end)
                vim.schedule(function() vim.cmd("MasonToolsUpdate") end)
              end,
              key = 'u',
            },
            {
              icon = ' ',
              desc = 'Files',
              group = 'Function',
              action = 'Telescope find_files find_command=rg,--ignore,--hidden,--files',
              key = 'f',
            },
            -- {
            --   icon = ' ',
            --   desc = 'Apps',
            --   group = 'String',
            --   action = 'Telescope app',
            --   key = 'a',
            -- },
            -- {
            --   icon = ' ',
            --   desc = 'dotfiles',
            --   group = 'Constant',
            --   action = 'Telescope dotfiles',
            --   key = 'd',
            -- },
          },
          footer = {},
        },
      })
    end,
  },
}
