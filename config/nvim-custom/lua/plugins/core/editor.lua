return {
  -- automatic tab/space detection
  {
    "tpope/vim-sleuth",
    event = "LazyFile",
  },

  -- task worker
  {
    "tpope/vim-dispatch",
    cmd = {
      "Dispatch",
      "FocusDispatch",
      "Make",
      "Spawn",
      "Start",
      "Copen",
      "Focus",
      "AbortDispatch",
    },
  },

  -- search/replace
  -- {
  --   "MagicDuck/grug-far.nvim",
  --   opts = { headerMaxWidth = 80 },
  --   cmd = "GrugFar",
  --   keys = {
  --     {
  --       "<leader>sr",
  --       function()
  --         local grug = require("grug-far")
  --         local ext = vim.bo.buftype == "" and vim.fn.expand("%:e")
  --         grug.open({
  --           transient = true,
  --           prefills = {
  --             filesFilter = ext and ext ~= "" and "*." .. ext or nil,
  --           },
  --         })
  --       end,
  --       mode = { "n", "v" },
  --       desc = "Search and Replace",
  --     },
  --   },
  -- },

  -- {
  --   "folke/flash.nvim",
  --   event = "VeryLazy",
  --   vscode = true,
  --   opts = {},
  --   -- stylua: ignore
  --   keys = {
  --     { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
  --     { "S", mode = { "n", "o", "x" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
  --     { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
  --     { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
  --     { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
  --   },
  -- },

  -- {
  --   "folke/todo-comments.nvim",
  --   -- cmd = { "TodoTrouble", "TodoTelescope" },
  --   event = "LazyFile",
  --   opts = {},
  --   -- stylua: ignore
  --   keys = {
  --     { "]t", function() require("todo-comments").jump_next() end, desc = "Next Todo Comment" },
  --     { "[t", function() require("todo-comments").jump_prev() end, desc = "Previous Todo Comment" },
  --     -- { "<leader>xt", "<cmd>Trouble todo toggle<cr>", desc = "Todo (Trouble)" },
  --     -- { "<leader>xT", "<cmd>Trouble todo toggle filter = { tag = {TODO,FIX,FIXME}}<cr>", desc = "Todo/Fix/Fixme (Trouble)" },
  --   },
  -- },

  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show({ global = false })
        end,
        desc = "Buffer Keymaps (which-key)",
      },
      {
        "<c-w><space>",
        function()
          require("which-key").show({ keys = "<c-w>", loop = true })
        end,
        desc = "Window Hydra Mode (which-key)",
      },
    },
    opts = {
      preset = "modern",
      deafults = {},
      spec = {
        {
          mode = { "n", "v" },
          { "<leader><tab>", group = "tabs" },
          { "<leader>c", group = "code" },
          { "<leader>d", group = "debug" },
          { "<leader>f", group = "file/find" },
          { "<leader>g", group = "git" },
          { "<leader>s", group = "search" },
          { "<leader>t", group = "terminal/test" },
          { "<leader>u", group = "ui" },
          { "<leader>q", group = "session" },
          { "<leader>x", group = "diagnostics" },
          { "[", group = "prev" },
          { "]", group = "next" },
          { "g", group = "goto" },
          { "gs", group = "surround" },
          { "z", group = "fold" },
          { "<BS>", desc = "Decrement Selection", mode = "x" },
          { "<c-space>", desc = "Increment Selection", mode = { "x", "n" } },
          {
            "<leader>b",
            group = "buffer",
            expand = function()
              return require("which-key.extras").expand.buf()
            end,
          },
          {
            "<leader>w",
            group = "windows",
            proxy = "<c-w>",
            expand = function()
              return require("which-key.extras").expand.win()
            end,
          },
        },
      },
    },
  },
}
