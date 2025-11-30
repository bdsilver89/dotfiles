return {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },

  {
    "stevearc/oil.nvim",
    keys = {
      { "-", "<cmd>Oil<cr>", desc = "Oil file explorer" },
    },
    opts = {},
  },

  {
    "tpope/vim-sleuth",
    lazy = false,
  },

  {
    "christoomey/vim-tmux-navigator",
    lazy = false,
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateRight",
      "TmuxNavigateUp",
      "TmuxNavigateDown",
      "TmuxNavigatePrevious",
    },
    keys = {
      { "<c-h>", "<cmd>TmuxNavigateLeft<cr>", desc = "Go to left pane" },
      { "<c-j>", "<cmd>TmuxNavigateDown<cr>", desc = "Go to lower pane" },
      { "<c-k>", "<cmd>TmuxNavigateUp<cr>", desc = "Go to upper pane" },
      { "<c-l>", "<cmd>TmuxNavigateRight<cr>", desc = "Go to right pane" },
      { "<c-\\>", "<cmd>TmuxNavigatePrevious<cr>", desc = "Go to previous pane" },
    },
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if opts.ensure_installed then
        opts.ensure_installed = vim.tbl_filter(function(lang)
          return lang ~= "jsonc"
        end, opts.ensure_installed)
      end
    end,
  },

  {
    "sidekick.nvim",
    optional = true,
    keys = {
      {
        "<leader>ag",
        function()
          require("sidekick.cli").toggle({ name = "gemini", focus = true })
        end,
        desc = "Sidekick Gemini Toggle",
      },
    },
    opts = {
      mux = {
        backend = "tmux",
      },
    },
  },

  {
    "kulala.nvim",
    optional = true,
    opts = function(_, opts)
      if LazyVim.has("edgy.nvim") then
        opts.ui = opts.ui or {}
        opts.ui.show = false
      end
    end,
  },

  {
    "edgy.nvim",
    optional = true,
    opts = function(_, opts)
      opts.right = opts.right or {}
      table.insert(opts.right, {
        title = "Sidekick",
        ft = "sidekick_terminal",
        size = { width = 80 },
      })

      opts.bottom = opts.bottom or {}
      table.insert(opts.bottom, {
        title = "Kulala",
        ft = "kulala",
        size = { height = 15 },
        filter = function(buf, win)
          return vim.bo[buf].filetype == "kulala"
        end,
      })
    end,
  },
}
