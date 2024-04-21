return {
  -- LazyVim
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },

  -- telescope
  {
    "nvim-telescope/telescope.nvim",
    opts = {
      defaults = {
        sorting_strategy = "ascending",
        layout_config = {
          prompt_position = "top",
        },
      },
    },
  },

  -- oil as primary file explorer
  {
    "stevearc/oil.nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    -- stylua: ignore
    keys = {
      { "<leader>e", function() require("oil").open_float(LazyVim.root()) end, desc = "Explorer Oil (root)" },
      { "<leader>E", function() require("oil").open_float() end, desc = "Explorer Oil (cwd)" },
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

  -- remove neo-tree keymaps that conflict with oil
  {
    "nvim-neo-tree/neo-tree.nvim",
    keys = function(_, mappings)
      return vim.tbl_filter(
        ---@param mapping LazyKeysSpec
        function(mapping)
          if mapping[1] == "<leader>e" or mapping[1] == "<leader>E" then
            return false
          end
          return true
        end,
        mappings
      )
    end,
  },

  -- undotree
  {
    "mbbill/undotree",
    keys = {
      { "<leader>u", "<cmd>UndotreeToggle<cr>", "Undotree" },
    },
  },

  -- tmux/vim compat
  {
    "christoomey/vim-tmux-navigator",
    lazy = false,
  },

  -- expand git functionality
  -- NOTE: should consider dinhhuy258/git.nvim as lua rewrite of this?
  {
    "tpope/vim-fugitive",
    event = "LazyFile",
  },
}
