return {
  {
    "stevearc/oil.nvim",
    dependencies = {
      { "nvim-tree/nvim-web-devicons", optional = true },
    },
    -- stylua: ignore
    keys = {
      { "<leader>e", function() require("oil").open() end, desc = "File explorer (oil)" },
      -- { "<leader>E", function() require("oil").open() end,         desc = "File explorer (oil)" },
    },
    cmd = "Oil",
    opts = {
      win_opts = {
        signcolumn = "number",
      },
      columns = { "icon" },
    },
    init = function()
      if vim.fn.argc(-1) == 1 then
        local stat = vim.uv.fs_stat(vim.fn.argv(0))
        if stat and stat.type == "directory" then
          require("oil").open(vim.fn.argv(0))
        end
      end
    end,
    config = true,
  },
}
