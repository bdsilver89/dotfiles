return {
  {
    "stevearc/oil.nvim",
    dependencies = {
			{ "nvim-tree/nvim-web-devicons", optional = true },
    },
    -- stylua: ignore
    keys = {
      { "<leader>o", function() require("oil").open_float() end, desc = "File explorer (oil)" },
    },
    cmd = "Oil",
    opts = {
      win_opts = {
        signcolumn = "number",
      },
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
