return {
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    -- stylua: ignore
    keys = {
      { "<leader>qs", function() require("persistence").load() end, desc = "Restore session" },
      { "<leader>ql", function() require("persistence").load({ last = true }) end, desc = "Restore last session" },
      { "<leader>qd", function() require("persistence").stop() end, desc = "Don't save current session" },
    },
    opts = {
      options = {
        "buffers",
        "curdir",
        "tabpages",
        "winsize",
        "help",
        "globals",
        "skiprtp",
      },
    },
  },
  {
    "ahmedkhalf/project.nvim",
    event = "VeryLazy",
    opts = {
      manual_mode = true,
    },
    config = function(_, opts)
      require("project_nvim").setup(opts)
      require("utils").on_load("telescope.nvim", function()
        require("telescope").load_extension("projects")
      end)
    end,
  },
}
