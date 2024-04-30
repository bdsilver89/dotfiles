return {
  -- nerd icons
  {
    "nvim-tree/nvim-web-devicons",
    lazy = true,
    enabled = vim.g.have_nerd_font
  },

  -- ui tools
  {
    "MunifTanjim/nui.nvim",
    lazy = true,
  },

  -- catppuccin colorscheme
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    init = function()
      vim.cmd.colorscheme("catppuccin")
    end,
  },

  -- indent lines
  {
    "lukas-reineke/indent-blankline.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      indent = {
        char = "│",
        tab_char = "│",
      },
      scope = { enabled = true },
      exclude = {
        filetypes = {
          "help",
          "alpha",
          "dashboard",
          "neo-tree",
          "Trouble",
          "trouble",
          "lazy",
          "mason",
          "notify",
          "toggleterm",
          "lazyterm",
        },
      },
    },
    main = "ibl",
  },

  -- dashboard
  {
    "nvimdev/dashboard-nvim",
    event = "VimEnter",
    opts = function()
      local opts = {
        theme = "doom",
        hide = {
          statusline = false,
        },
        config = {
          center = {
            { action = "ene | startinsert", desc = " New File", key = "n" },
            { action = "Telescope oldfiles", desc = " Recent Files", key = "r" },
            { action = "Telescope live_grep", desc = " Find Text", key = "g" },
            { action = "Lazy", desc = " Lazy", key = "l" },
            { action = "qa", desc = " Quit", key = "q" },
          },
          -- footer = function()
          --   local stats = require()
          -- end,
        },
      }
      -- for _, button in ipairs(opts.config.center) do
      -- end

      if vim.o.filetype == "lazy" then
        vim.cmd.close()
        vim.api.nvim_create_autocmd("User", {
          pattern = "DashboardLoaded",
          callback = function()
            require("lazy").show()
          end,
        })
      end

      return opts
    end,
  },
}
