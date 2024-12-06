return {
  {
    "stevearc/oil.nvim",
    keys = {
      {
        "-",
        function()
          require("oil").open()
        end,
        desc = "Explorer Oil (Root Dir)",
      },
      {
        "_",
        function()
          require("oil").open(vim.uv.cwd())
        end,
        desc = "Explorer Oil (cwd)",
      },
    },
    opts = {},
  },
}
