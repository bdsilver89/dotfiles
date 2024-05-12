return {
  -- icon pack
  {
    "nvim-tree/nvim-web-devicons",
    enabled = vim.g.enable_icons,
    lazy = true,
    -- dependencies = {
    --   {
    --     "DaikyXendo/nvim-material-icon",
    --     enabled = vim.g.enable_icons and vim.g.enable_material_icons,
    --   },
    -- },
    -- opts = function()
    --   local devicons = require("nvim-web-devicons")
    --   local has_material_icon, material_icon = pcall(require, "material_icons")
    --
    --   local opts = {}
    --   if has_material_icon then
    --     opts.override = material_icon.get_icons()
    --   end
    --   return opts
    -- end,
    -- config = function(_, opts)
    --   require("nvim-web-devicons").setup(opts)
    -- end,
  },

  -- ui components
  {
    "MunifTanjim/nui.nvim",
    lazy = true,
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
    "rcarriga/nvim-notify",
    keys = {
      {
        "<leader>un",
        function()
          require("notify").dismiss({ silent = true, pending = true })
        end,
        desc = "Dismiss notifications",
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
  },

  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
    },
    opts = {
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
      },
      routes = {
        {
          filter = {
            event = "msg_show",
            any = {
              { find = "%d+L, %d+B" },
              { find = "; after #%d+" },
              { find = "; before #%d+" },
            },
          },
          view = "mini",
        },
      },
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
        inc_rename = true,
      },
    },
    -- stylua: ignore
    keys = {
      { "<S-Enter>", function() require("noice").redirect(vim.fn.getcmdline()) end, mode = "c", desc = "Redirect Cmdline" },
      { "<leader>ml", function() require("noice").cmd("last") end, desc = "Noice Last Message" },
      { "<leader>mh", function() require("noice").cmd("history") end, desc = "Noice History" },
      { "<leader>ma", function() require("noice").cmd("all") end, desc = "Noice All" },
      { "<leader>md", function() require("noice").cmd("dismiss") end, desc = "Dismiss All" },
      { "<c-f>", function() if not require("noice.lsp").scroll(4) then return "<c-f>" end end, silent = true, expr = true, desc = "Scroll Forward", mode = {"i", "n", "s"} },
      { "<c-b>", function() if not require("noice.lsp").scroll(-4) then return "<c-b>" end end, silent = true, expr = true, desc = "Scroll Backward", mode = {"i", "n", "s"}},
    },
  },
}
