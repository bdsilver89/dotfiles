return {

  -- tree file explorer
  {
    "nvim-neo-tree/neo-tree.nvim",
    cmd = "Neotree",
    dependencies = {
      { "nvim-lua/plenary.nvim", lazy = true },
      { "MunifTanjim/nui.nvim", lazy = true },
    },
    keys = {
      { "<leader>e", "<leader>fe", desc = "File explorer (neo-tree)", remap = true },
      {
        "<leader>fe",
        function()
          require("neo-tree.command").execute({ toggle = true })
        end,
        desc = "File explorer (neo-tree)"
      },
      {
        "<leader>be",
        function()
          require("neo-tree.command").execute({ toggle = true, source = "buffers" })
        end,
        desc = "Buffer explorer (neo-tree)"
      },
      {
        "<leader>ge",
        function()
          require("neo-tree.command").execute({ toggle = true, source = "git_status" })
        end,
        desc = "Git explorer (neo-tree)"
      },
    },
    opts = {
      close_if_last_window = true,
      sources = {
        "filesystem",
        "buffers",
        "git_status",
      },
      source_selector = {
        winbar = true,
        content_layout = "center",
        sources = {
          { source = "filesystem" },
          { source = "buffers" },
          { source = "git_status" },
          { source = "diagnostics" },
        },
      },
      filesystem = {
        bind_to_cwd = false,
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = true,
      },
    },
  },

  -- oil file explorer
  {
    "stevearc/oil.nvim",
    cmd = "Oil",
    keys = {
      { "<leader>o", function() require("oil").open() end, desc = "File explorer (oil)" },
    },
    opts = {},
  },
}
