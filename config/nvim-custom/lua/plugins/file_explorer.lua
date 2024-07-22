return {
  -- buffer-based file explorer
  {
    "stevearc/oil.nvim",
    cmd = "Oil",
    keys = {
      {
        "<leader>o",
        function()
          require("oil").open()
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
    },
  },

  -- file tree
  {
    "nvim-neo-tree/neo-tree.nvim",
    cmd = "Neotree",
    keys = {
      {
        "<leader>fe",
        function()
          require("neo-tree.command").execute({ toggle = true })
        end,
        desc = "File explorer (Neotree)",
      },
      { "<leader>e", "<leader>fe", desc = "File explorer (Neotree)", remap = true },
      {
        "<leader>ge",
        function()
          require("neo-tree.command").execute({ toggle = true, source = "git_status" })
        end,
        desc = "Git explorer (Neotree)",
      },
      {
        "<leader>be",
        function()
          require("neo-tree.command").execute({ toggle = true, source = "buffers" })
        end,
        desc = "Buffer explorer (Neotree)",
      },
    },
    opts = {
      sources = { "filesystem", "buffers", "git_status" },
      source_selector = {
        winbar = true,
        content_layout = "center",
        sources = {
          { source = "filesystem" },
          { source = "buffers" },
          { source = "diagnostics" },
          { source = "git_status" },
        },
        filesystem = {
          bind_to_cwd = false,
          follow_current_file = {
            enabled = true,
          },
          use_libuv_file_watcher = true,
        },
        window = {
          mappings = {
            ["l"] = "open",
            ["h"] = "close_node",
            ["<space>"] = "none",
            ["P"] = { "toggle_preview", config = { use_float = false } },
          },
        },
        default_component_configs = {
          indent = {
            with_expanders = true,
          },
        },
      },
    },
  },
}
