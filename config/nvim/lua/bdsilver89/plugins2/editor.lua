return {
  -- adjust tabstop and shiftwidth automatically
  "tpope/vim-sleuth",

  -- vim/tmux navigation
  "christoomey/vim-tmux-navigator",

  -- oil as primary file explorer
  {
    "stevearc/oil.nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    -- stylua: ignore
    keys = {
      { "<leader>e", function() require("oil").open_float() end, desc = "Explorer (oil)" },
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

  -- undotree
  {
    "mbbill/undotree",
    keys = {
      { "<leader>u", "<cmd>UndotreeToggle<cr>", "Undotree" },
    },
  },
}
