return {
  {
    "NMAC427/guess-indent.nvim",
    event = { "BufReadPost" },
    cmd = "GuessIndent",
    opts = {
      auto_cmd = true,
    },
  },

  {
    "alexghergh/nvim-tmux-navigation",
    keys = {
      { "<c-h>", "<cmd>NvimTmuxNavigateLeft<cr>" },
      { "<c-j>", "<cmd>NvimTmuxNavigateDown<cr>" },
      { "<c-k>", "<cmd>NvimTmuxNavigateUp<cr>" },
      { "<c-l>", "<cmd>NvimTmuxNavigateRight<cr>" },
    },
    opts = {},
  },

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
  {
    "nvim-tree/nvim-tree.lua",
    cmd = { "NvimTreeToggle", "NvimTreeFocus" },
    keys = {
      { "<leader>e", "<cmd>NvimTreeToggle<cr>", desc = "File explorer (tree)" },
    },
    opts = {
      -- filters = { dotfiles = false },
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
        root_folder_label = false,
        highlight_git = true,
        indent_markers = {
          enable = true,
        },
        icons = {
          glyphs = {
            default = "󰈚",
            folder = {
              default = "",
              empty = "",
              empty_open = "",
              open = "",
              symlink = "",
            },
            git = { unmerged = "" },
          },
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
