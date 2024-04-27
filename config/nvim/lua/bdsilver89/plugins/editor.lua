return {
  -- adjust tabstop and shiftwidth automatically
  "tpope/vim-sleuth",

  -- vim/tmux navigation
  "christoomey/vim-tmux-navigator",

  -- telescope
  {
    "nvim-telescope/telescope.nvim",
    event = "VimEnter",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        cond = function()
          return vim.fn.executable("make") == 1
        end,
      },
    },
    opts = function()
      return {
        defaults = {
          sorting_strategy = "ascending",
          layout_config = {
            prompt_position = "top",
          },
        },
        extensions = {},
        mappings = {},
      }
    end,
    config = function(_, opts)
      require("telescope").setup(opts)

      pcall(require("telescope").load_extension, "fzf")
    end,
  },

  -- harpoon for file nav (use the new harpoon2 branch)
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    keys = function()
      local keys = {
        {
          "<leader>H",
          function()
            require("harpoon"):list():add()
          end,
          desc = "Harpoon File",
        },
        {
          "<leader>h",
          function()
            local harpoon = require("harpoon")
            harpoon.ui:toggle_quick_menu(harpoon:list())
          end,
          desc = "Harpoon Quick Menu",
        },
      }

      for i = 1, 5 do
        table.insert(keys, {
          "<leader>" .. i,
          function()
            require("harpoon"):list():select(i)
          end,
          desc = "Harpoon to File " .. i,
        })
      end
      return keys
    end,
    opts = {
      menu = {
        width = vim.api.nvim_win_get_width(0) - 4,
      },
      settings = {
        save_on_toggle = true,
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
