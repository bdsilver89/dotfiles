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

  {
    "folke/todo-comments.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {},
    keys = {
      {
        "]t",
        function()
          require("todo-comments").jump_next()
        end,
        desc = "Next todo",
      },
      {
        "[t",
        function()
          require("todo-comments").jump_prev()
        end,
        desc = "Prev todo",
      },
    },
  },

  {
    "stevearc/aerial.nvim",
    event = { "BufReadPost", "BufNewFile" },
    keys = {
      { "<leader>cs", "<cmd>AerialToggle<cr>", desc = "Symbols" },
      { "<leader>cn", "<cmd>AerialNavToggle<cr>", desc = "Symbols nav" },
    },
    opts = {},
  },

  {
    "folke/which-key.nvim",
    event = { "BufReadPost", "BufNewFile" },
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show({ global = false })
        end,
        desc = "Buffer local keymaps",
      },
    },
    opts = {
      spec = {
        {
          mode = { "n", "v" },
          { "<leader><tab>", group = "tab" },
          { "<leader>b", group = "buffer" },
          { "<leader>c", group = "code" },
          { "<leader>d", group = "debug" },
          { "<leader>f", group = "file/find" },
          { "<leader>g", group = "git" },
          { "<leader>gh", group = "hunk" },
          { "<leader>m", group = "harpoon" },
          { "<leader>o", group = "overseer" },
          { "<leader>s", group = "search" },
          { "<leader>t", group = "terminal" },
          { "<leader>T", group = "test" },
          { "<leader>u", group = "ui" },
          { "<leader>w", group = "windows" },
          { "<leader>x", group = "diagnostics" },
          { "<leader>q", group = "session" },
          { "[", group = "prev" },
          { "]", group = "next" },
          { "g", group = "goto" },
          { "gs", group = "surround" },
          { "z", group = "fold" },
        },
      },
    },
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts)
    end,
  },
}
