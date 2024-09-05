return {
  -- buffer-based file explorer
  {
    "stevearc/oil.nvim",
    cmd = "Oil",
    keys = {
      {
        "<leader>o",
        function()
          require("oil").open_float()
        end,
        desc = "File explorer (oil)",
      },
    },
    opts = {
      default_file_explorer = true,
      skip_confirm_for_simple_edits = true,
      view_options = {
        show_hidden = true,
        natural_order = true,
        is_always_hidden = function(name)
          return name == ".." or name == ".git"
        end,
      },
      float = {
        border = "rounded",
      },
    },
  },

  -- file tree
  -- {
  --   "nvim-neo-tree/neo-tree.nvim",
  --   eanbled = false,
  --   cmd = "Neotree",
  --   keys = {
  --     {
  --       "<leader>fe",
  --       function()
  --         require("neo-tree.command").execute({ toggle = true })
  --       end,
  --       desc = "File explorer (Neotree)",
  --     },
  --     { "<leader>e", "<leader>fe", desc = "File explorer (Neotree)", remap = true },
  --     {
  --       "<leader>ge",
  --       function()
  --         require("neo-tree.command").execute({ toggle = true, source = "git_status" })
  --       end,
  --       desc = "Git explorer (Neotree)",
  --     },
  --     {
  --       "<leader>be",
  --       function()
  --         require("neo-tree.command").execute({ toggle = true, source = "buffers" })
  --       end,
  --       desc = "Buffer explorer (Neotree)",
  --     },
  --   },
  --   opts = {
  --     sources = { "filesystem", "buffers", "git_status" },
  --     source_selector = {
  --       winbar = true,
  --       content_layout = "center",
  --       sources = {
  --         { source = "filesystem" },
  --         { source = "buffers" },
  --         { source = "diagnostics" },
  --         { source = "git_status" },
  --       },
  --     },
  --     filesystem = {
  --       bind_to_cwd = false,
  --       follow_current_file = {
  --         enabled = true,
  --       },
  --       use_libuv_file_watcher = true,
  --     },
  --     window = {
  --       mappings = {
  --         ["l"] = "open",
  --         ["h"] = "close_node",
  --         ["<space>"] = "none",
  --         ["P"] = { "toggle_preview", config = { use_float = false } },
  --       },
  --     },
  --     default_component_configs = {
  --       indent = {
  --         with_expanders = true,
  --       },
  --     },
  --   },
  -- },

  {
    "nvim-tree/nvim-tree.lua",
    cmd = { "NvimTreeToggle", "NvimTreeFocus" },
    keys = {
      { "<leader>e", "<cmd>NvimTreeToggle<cr>", desc = "File explorer (tree)" },
    },
    opts = {
      disable_netrw = true,
      hijack_cursor = true,
      sync_root_with_cwd = true,
      update_focused_file = {
        enable = true,
        update_root = false,
      },
      view = {
        width = 30,
        preserve_window_proportions = true,
      },
      renderer = {
        highlight_git = true,
        indent_markers = {
          enable = true,
        },
      },
    },
  },

  -- harpoon file navigation
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    opts = {
      menu = {
        width = vim.api.nvim_win_get_width(0) - 4,
      },
      settings = {
        save_on_toggle = true,
      },
    },
    keys = function()
      local keys = {
        {
          "<leader>ma",
          function()
            require("harpoon"):list():add()
          end,
          desc = "Harpoon file",
        },
        {
          "<leader>mt",
          function()
            local harpoon = require("harpoon")
            harpoon.ui:toggle_quick_menu(harpoon:list(), { border = "rounded" })
          end,
          desc = "Harpoon menu",
        },
      }

      for i = 1, 5 do
        table.insert(keys, {
          "<leader>m" .. i,
          function()
            require("harpoon"):list():select(i)
          end,
          desc = "Harpoon to file " .. i,
        })
      end
      return keys
    end,
  },
}
