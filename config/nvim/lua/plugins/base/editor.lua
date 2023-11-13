local Utils = require("utils")

return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    cmd = "NeoTree",
    -- stylua: ignore
    keys = {
      { "<leader>e", function() require("neo-tree.command").execute({ toggle = true }) end, desc = "Explorer" },
      { "<leader>ge", function() require("neo-tree.command").execute({ source = "git_status", toggle = true }) end, desc = "Git explorer" },
      { "<leader>be", function() require("neo-tree.command").execute({ source = "buffers", toggle = true }) end, desc = "Buffer explorer" },
    },
    deactivate = function()
      vim.cmd([[eotree close]])
    end,
    init = function()
      if vim.fn.argc(-1) == 1 then
        local stat = vim.loop.fs_stat(vim.fn.argv(0))
        if stat and stat.type == "directory" then
          require("neo-tree")
        end
      end
    end,
    opts = function()
      return {
        sources = { "filesystem", "buffers", "git_status", "document_symbols" },
        open_files_do_not_replace_types = { "terminal", "Trouble", "trouble", "qf", "Outline", "edgy" },
        filesystem = {
          bind_to_cwd = false,
          follow_current_file = { enabled = true },
          use_libuv_file_watcher = true,
        },
        window = {
          mappings = {
            ["<space>"] = "none",
          },
        },
        default_component_configs = {
          modified = { symbol = Utils.icons.file.modified },
          git_status = {
            symbols = {
              added = Utils.icons.git.added,
              deleted = Utils.icons.git.deleted,
              modified = Utils.icons.git.modified,
              renamed = Utils.icons.git.renamed,
              untracked = Utils.icons.git.untracked,
              ignored = Utils.icons.git.ignored,
              unstaged = Utils.icons.git.unstaged,
              staged = Utils.icons.git.staged,
              conflict = Utils.icons.git.conflict,
            },
          },
        },
      }
    end,
  },
  {
    "ThePrimeagen/harpoon",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
    -- stylua: ignore
    keys = {
      { "<leader>ma", function() require("harpoon.mark").add_file() end, desc = "Add file" },
      { "<leader>sm", "<cmd>Telescope harpoon marks<cr>", desc = "Harpoon marks" },
      { "<leader>mm", function() require("harpoon.ui").toggle_quick_menu() end, desc = "Menu" },
      { "<leader>m1", function() require("harpoon.ui").nav_file(1) end, desc = "Nav file 1" },
      { "<leader>m2", function() require("harpoon.ui").nav_file(2) end, desc = "Nav file 2" },
      { "<leader>m3", function() require("harpoon.ui").nav_file(3) end, desc = "Nav file 3" },
      { "<leader>m4", function() require("harpoon.ui").nav_file(4) end, desc = "Nav file 4" },
      { "<leader>m5", function() require("harpoon.ui").nav_file(5) end, desc = "Nav file 5" },
      { "<leader>m6", function() require("harpoon.ui").nav_file(6) end, desc = "Nav file 6" },
      { "<leader>m7", function() require("harpoon.ui").nav_file(7) end, desc = "Nav file 7" },
      { "<leader>m8", function() require("harpoon.ui").nav_file(8) end, desc = "Nav file 8" },
      { "<leader>m9", function() require("harpoon.ui").nav_file(9) end, desc = "Nav file 9" },
      { "<leader>sm", function() require("harpoon.ui").toggle_quick_menu() end, desc = "Menu" },
      { "<leader>mf", function()
        require("harpoon.term").sendCommand(1, "tmux-sessionizer\n")
        require("harpoon.term").gotoTerminal(1)
      end, desc = "Tmux sessionizer"},
    },
    opts = {
      global_settings = {
        save_on_toggle = true,
        enter_on_sendcmd = true,
        mark_branch = true,
      },
    },
    config = function(_, opts)
      require("harpoon").setup(opts)
      require("telescope").load_extension("harpoon")
    end,
  },
  {
    "nvim-pack/nvim-spectre",
    cmd = "Spectre",
    opts = {
      open_cmd = "noswapfile vnew",
    },
    -- stylua: ignore
    keys = {
      { "<leader>sr", function() require("spectre").open() end, desc = "Find/replace in files" },
    },
  },
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    vscode = true,
    opts = {},
    -- stylua: ignore
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Treesitter" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote flash" },
      { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter search" },
      { "<c-s>", mode = "c", function() require("flash").toggle() end, desc = "Toggle flash search" },
    },
  },
  {
    "folke/trouble.nvim",
    cmd = { "TroubleToggle", "Trouble" },
    opts = { use_diagnostics_signs = true },
    keys = {
      { "<leader>xx", "<cmd>TroubleToggle document_diagnostics<cr>", desc = "Document diagnostics (Trouble)" },
      { "<leader>xX", "<cmd>TroubleToggle workspace_diagnostics<cr>", desc = "Workspace diagnostics (Trouble)" },
      { "<leader>xL", "<cmd>TroubleToggle loclist<cr>", desc = "Location list (Trouble)" },
      { "<leader>xQ", "<cmd>TroubleToggle quickfix<cr>", desc = "Quickfix list (Trouble)" },
      {
        "[q",
        function()
          if require("trouble").is_open() then
            require("trouble").previous({ skip_groups = true, jump = true })
          else
            local ok, err = pcall(vim.cmd.cprev)
            if not ok then
              vim.notify(err, vim.log.levels.ERROR)
            end
          end
        end,
        desc = "Previous trouble/quickfix item",
      },
      {
        "]q",
        function()
          if require("trouble").is_open() then
            require("trouble").next({ skip_groups = true, jump = true })
          else
            local ok, err = pcall(vim.cmd.cnext)
            if not ok then
              vim.notify(err, vim.log.levels.ERROR)
            end
          end
        end,
        desc = "Next trouble/quickfix item",
      },
    },
  },
  {
    "folke/todo-comments.nvim",
    cmd = { "TodoTrouble", "TodoTelescope" },
    -- event = { "BufReadPost", "BufNewFile" },
    event = "LazyFile",
    keys = {
      {
        "]t",
        function()
          require("todo-comments").jump_next()
        end,
        desc = "Next todo comment",
      },
      {
        "[t",
        function()
          require("todo-comments").jump_prev()
        end,
        desc = "Prev todo comment",
      },
      { "<leader>xt", "<cmd>TodoTrouble<cr>", desc = "Todo (trouble)" },
      { "<leader>xT", "<cmd>TodoTrouble keywords=TODO,FIX,FIXME<cr>", desc = "Todo/Fix/Fixme (trouble)" },
      { "<leader>st", "<cmd>TodoTelescope<cr>", desc = "Todo (telescope)" },
      { "<leader>sT", "<cmd>TodoTelescope keywords=TODO,FIX,FIXME<cr>", desc = "Todo/Fix/Fixme (telescope)" },
    },
    config = true,
  },
  {
    "mbbill/undotree",
    keys = {
      { "<leader>cu", "<cmd>UndotreeToggle<cr>", desc = "Undotree" },
    },
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      plugins = { spelling = true },
      defaults = {
        mode = { "n", "v" },
        ["g"] = { name = "+goto" },
        ["["] = { name = "+next" },
        ["]"] = { name = "+prev" },
        ["z"] = { name = "+folds" },
        ["<leader><tab>"] = { name = "+tabs" },
        ["<leader>b"] = { name = "+buffer" },
        ["<leader>c"] = { name = "+code" },
        ["<leader>cg"] = { name = "+generate" },
        ["<leader>d"] = { name = "+debug" },
        ["<leader>f"] = { name = "+find" },
        ["<leader>g"] = { name = "+git" },
        ["<leader>gh"] = { name = "+hunk" },
        ["<leader>gt"] = { name = "+toggle" },
        ["<leader>m"] = { name = "+marks" },
        ["<leader>r"] = { name = "+refactor" },
        ["<leader>s"] = { name = "+search" },
        ["<leader>t"] = { name = "+test" },
        ["<leader>u"] = { name = "+ui" },
        ["<leader>w"] = { name = "+windows" },
        ["<leader>x"] = { name = "+diagnostics/quickfix" },
        ["<leader>z"] = { name = "+zen" },
      },
    },
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts)
      wk.register(opts.defaults)
    end,
  },
}
