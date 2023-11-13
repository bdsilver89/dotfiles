return {
  "nvim-tree/nvim-web-devicons",
  "MunifTanjim/nui.nvim",
  {
    "rcarriga/nvim-notify",
    keys = {
      {
        "<leader>un",
        function()
          require("notify").dismiss({ silent = true, pending = true })
        end,
        desc = "Dismiss all notifications",
      },
    },
  },
  {
    "stevearc/dressing.nvim",
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
    "folke/noice.nvim",
    event = "VeryLazy",
    -- stylua: ignore
    keys = {
      { "<s-enter>", function() require("noice").redirect(vim.fn.getcmdline()) end, mode = "c", desc = "Redirect cmdline" },
      { "<leader>snl", function() require("noice").cmd("last") end, desc = "Noice last message" },
      { "<leader>snh", function() require("noice").cmd("history") end, desc = "Noice history" },
      { "<leader>sna", function() require("noice").cmd("all") end, desc = "Noice all" },
      { "<leader>snd", function() require("noice").cmd("dismiss") end, desc = "Noice dismiss all" },
      { "<c-f>", function() if not require("noice.lsp").scroll(4) then return "<c-f>" end end, silent = true, expr = true, desc = "Scroll forward",mode = { "i", "n", "s"} },
      { "<c-b>", function() if not require("noice.lsp").scroll(-4) then return "<c-b>" end end, silent = true, expr = true, desc = "Scroll backward", mode = { "i", "n", "s"} },
    },
    opts = {
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp_util.stylize_markdown"] = true,
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
  },
  {
    "NvChad/nvim-colorizer.lua",
    event = { "BufReadPost", "BufNewFile" },
    config = true,
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    event = "LazyFile",
    main = "ibl",
    opts = {
      scope = {
        show_start = false,
        show_end = false,
      },
      exclude = {
        buftypes = {
          "nofile",
          "terminal",
        },
        filetypes = {
          "help",
          "aerial",
          "alpha",
          "dashboard",
          "lazy",
          "neogitstatus",
          "NvimTree",
          "neo-tree",
          "toggleterm",
          "Trouble",
        },
      },
    },
  },
  {
    "nvimdev/dashboard-nvim",
    event = "VimEnter",
    opts = function()
      local logo = {
        "",
        " ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗ ",
        " ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║ ",
        " ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║ ",
        " ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║ ",
        " ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║ ",
        " ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝ ",
        "",
      }

      local opts = {
        theme = "doom",
        hide = {
          statusline = false,
        },
        config = {
          header = logo,
          center = {
            { action = "Telescope find_files", desc = "Find file", key = "f" },
            { action = "ene | startinsert", desc = "New file", key = "n" },
            { action = "Telescope oldfiles", desc = "Recent files", key = "r" },
            { action = "Telescope live_grep", desc = "Find text", key = "g" },
            { action = "Telescope projects", desc = "Projects", key = "p" },
            { action = "lua require('persistence').load()", desc = "Restore session", key = "s" },
            {
              action = [[lua require('telescope.builtin').find_files({ cwd = vim.fn.stdpath('config') })]],
              desc = "Config",
              key = "c",
            },
            { action = "Lazy", desc = "Lazy", key = "l" },
            { action = "qa", desc = "Quit", key = "q" },
          },
          footer = function()
            local stats = require("lazy").stats()
            local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
            return {
              "",
              "",
              "Startuptime: " .. ms .. " ms",
              "Plugins: " .. stats.loaded .. " loaded / " .. stats.count .. " installed",
            }
          end,
        },
      }

      for _, button in ipairs(opts.config.center) do
        button.desc = button.desc .. string.rep(" ", 43 - #button.desc)
        button.key_format = "  %s"
      end

      -- close lazy and re-open when dashboard is ready
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
  {
    "folke/zen-mode.nvim",
    enabled = false,
    keys = {
      {
        "<leader>zz",
        function()
          require("zen-mode").toggle()
          vim.wo.wrap = false
          vim.wo.number = true
          vim.wo.relativenumber = true
        end,
        desc = "Zenmode",
      },
    },
  },
  {
    "folke/twilight.nvim",
    enabled = false,
    event = "LazyFile",
    opts = {},
  },
  {
    "folke/edgy.nvim",
    event = "VeryLazy",
    -- stylua: ignore
    keys = {
      { "<leader>ue", function() require("edgy").toggle() end, desc = "Edgy toggle" },
    },
    opts = function()
      return {
        -- keys = {
        --   ["<c-right>"] = function(win)
        --     win:resize("width", 2)
        --   end,
        --   ["<c-left>"] = function(win)
        --     win:resize("width", -2)
        --   end,
        --   ["<c-up>"] = function(win)
        --     win:resize("height", 2)
        --   end,
        --   ["<c-down>"] = function(win)
        --     win:resize("height", -2)
        --   end,
        -- },
        bottom = {
          "Trouble",
          {
            ft = "trouble",
            filter = function(_, win)
              return vim.api.nvim_win_get_config(win).relative == ""
            end,
          },
          -- {
          --   tf = "qf",
          --   title = "QuickFix",
          -- },
          {
            ft = "help",
            size = { height = 29 },
            filter = function(buf)
              return vim.bo[buf].buftype == "help"
            end,
          },
          {
            ft = "spectre_panel",
            title = "Spectre",
            size = { height = 0.4 },
          },
          {
            title = "Neotest Output",
            ft = "neotest-output-panel",
            size = { height = 15 },
          },
        },
        left = {
          {
            title = "Neo-Tree",
            ft = "neo-tree",
            filter = function(buf)
              return vim.b[buf].neo_tree_source == "filesystem"
            end,
            pinned = true,
            open = function()
              vim.api.nvim_input("<esc><space>e")
            end,
            size = { height = 0.5 },
          },
          { title = "Neotest Summary", ft = "neotest-summary" },
          {
            title = "Neo-Tree Git",
            ft = "neo-tree",
            filter = function(buf)
              return vim.b[buf].neo_tree_source == "git_status"
            end,
            pinned = true,
            open = "Neotree position=right git_status",
          },
          {
            title = "Neo-Tree Buffers",
            ft = "neo-tree",
            filter = function(buf)
              return vim.b[buf].neo_tree_source == "buffers"
            end,
            pinned = true,
            open = "Neotree position=top buffers",
          },
          "neo-tree",
        },
        right = {
          {
            ft = "aerial",
            title = "Aerial",
          },
        },
      }
    end,
  },
}
