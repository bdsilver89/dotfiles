return {
  {
    "stevearc/oil.nvim",
    keys = {
      {
        "<leader>fo",
        function()
          require("oil").open()
        end,
        desc = "Explorer Oil (Directory of Current File)",
      },
      {
        "<leader>fO",
        function()
          require("oil").open(vim.uv.cwd())
        end,
        desc = "Explorer Oil (cwd)",
      },
      {
        "<leader>o",
        "<leader>fo",
        desc = "Explorer Oil (Directory of Current File)",
        remap = true,
      },
      {
        "<leader>O",
        "<leader>fO",
        desc = "Explorer Oil (cwd)",
        remap = true,
      },
    },
    opts = {},
  },
}
