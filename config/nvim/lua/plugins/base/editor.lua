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
      vim.cmd([[Neotree close]])
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
    "nvim-telescope/telescope.nvim",
    dependencies = {
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        enabled = vim.fn.executable("make") == 1,
        build = "make",
        config = function()
          require("utils").on_load("telescope.nvim", function()
            require("telescope").load_extension("fzf")
          end)
        end,
      },
      {
        "nvim-telescope/telescope-symbols.nvim",
      },
      {
        "debugloop/telescope-undo.nvim",
        config = function()
          require("utils").on_load("telescope.nvim", function()
            require("telescope").load_extension("undo")
          end)
        end,
      },
      "project.nvim",
    },
    cmd = "Telescope",
    keys = {
      { "<leader>:", "<cmd>Telescope command_history<cr>", desc = "Command history" },
      { "<leader>/", "<cmd>Telescope live_grep<cr>", desc = "Grep" },
      { "<leader><space>", "<cmd>Telescope find_files<cr>", desc = "Find files" },
      -- find
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
      --{ "<leader>fc", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
      --{ "<leader>fF", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
      { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent" },
      { "<leader>fp", "<cmd>Telescope projects<cr>", desc = "Projects" },
      -- search
      { '<leader>s"', "<cmd>Telescope registers<cr>", desc = "Registers" },
      { "<leader>sa", "<cmd>Telescope autocommands<cr>", desc = "Autocommands" },
      { "<leader>sb", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Buffer" },
      { "<leader>sc", "<cmd>Telescope command_history<cr>", desc = "Command history" },
      { "<leader>sC", "<cmd>Telescope commands<cr>", desc = "Commands" },
      { "<leader>sd", "<cmd>Telescope diagnostics bufnr=0<cr>", desc = "Document diagnostics" },
      { "<leader>sD", "<cmd>Telescope diagnostics<cr>", desc = "Workspace diagnostics" },
      --{ "<leader>sg", "<cmd>Telescope diagnostics<cr>", desc = "Workspace diagnostics" },
      --{ "<leader>sG", "<cmd>Telescope diagnostics<cr>", desc = "Workspace diagnostics" },
      { "<leader>sh", "<cmd>Telescope help_tags<cr>", desc = "Help pages" },
      { "<leader>sH", "<cmd>Telescope highlights<cr>", desc = "Highlights" },
      { "<leader>sk", "<cmd>Telescope keymaps<cr>", desc = "Keymaps" },
      { "<leader>sM", "<cmd>Telescope man_pages<cr>", desc = "Man pages" },
      { "<leader>so", "<cmd>Telescope vim_options<cr>", desc = "Options" },
      { "<leader>sR", "<cmd>Telescope resume<cr>", desc = "Resume" },
      { "<leader>su", "<cmd>Telescope undo<cr>", desc = "Undo" },
      -- git
      { "<leader>gc", "<cmd>Telescope git_commits<cr>", desc = "Commits" },
      { "<leader>gs", "<cmd>Telescope git_status<cr>", desc = "Status" },
      { "<leader>gb", "<cmd>Telescope git_branches<cr>", desc = "Branches" },
    },
    opts = function()
      local actions = require("telescope.actions")

      local open_with_trouble = function(...)
        return require("trouble.providers.telescope").open_with_trouble(...)
      end
      local open_selected_with_trouble = function(...)
        return require("trouble.providers.telescope").open_selected_with_trouble(...)
      end
      -- local find_files_no_ignore = function()
      --   local action_state = require("telescope.actions.state")
      --   local line = action_state.get_current_line()
      --   Util.telescope("find_files", { no_ignore = true, default_text = line })()
      -- end
      -- local find_files_with_hidden = function()
      --   local action_state = require("telescope.actions.state")
      --   local line = action_state.get_current_line()
      --   Util.telescope("find_files", { hidden = true, default_text = line })()
      -- end

      local flash = function(prompt_bufnr)
        require("flash").jump({
          pattern = "^",
          label = { after = { 0, 0 } },
          search = {
            mode = "search",
            exclude = {
              function(win)
                return vim.bo[vim.api.nvim_win_get_buf(win)].filetype ~= "TelescopeResults"
              end,
            },
          },
          action = function(match)
            local picker = require("telescope.actions.state").get_current_picker(prompt_bufnr)
            picker:set_selection(match.pos[1] - 1)
          end,
        })
      end

      return {
        defaults = {
          path_display = { "truncate" },
          sorting_strategy = "ascending",
          get_selection_window = function()
            require("edgy").goto_main()
            return 0
          end,
          layout_config = {
            horizontal = {
              prompt_position = "top",
              preview_width = 0.55,
            },
            vertical = {
              mirror = false,
            },
            width = 0.87,
            height = 0.80,
            preview_cutoff = 120,
          },
          mappings = {
            i = {
              ["<c-t>"] = open_with_trouble,
              ["<a-t>"] = open_selected_with_trouble,
              ["<c-n>"] = actions.cycle_history_next,
              ["<c-p>"] = actions.cycle_history_prev,
              ["<c-j>"] = actions.move_selection_next,
              ["<c-k>"] = actions.move_selection_previous,
              ["<c-s>"] = flash,
            },
            n = {
              ["q"] = actions.close,
              ["s"] = flash,
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
    }
,
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
  {
    "RRethy/vim-illuminate",
    -- event = { "BufReadPost", "BufNewFile" },
    event = "LazyFile",
    keys = {
      { "]]", desc = "Next reference" },
      { "[[", desc = "Prev reference" },
    },
    opts = {
      delay = 200,
      large_file_cutoff = 2000,
      large_file_overrides = {
        providers = { "lsp" },
      },
    },
    config = function(_, opts)
      require("illuminate").configure(opts)

      local function map(key, dir, buffer)
        vim.keymap.set("n", key, function()
          require("illuminate")["goto_" .. dir .. "_reference"](false)
        end, { desc = dir:sub(1, 1):upper() .. dir:sub(2) .. " reference", buffer = buffer })
      end

      map("]]", "next")
      map("[[", "prev")

      vim.api.nvim_create_autocmd("FileType", {
        callback = function()
          local buffer = vim.api.nvim_get_current_buf()
          map("]]", "next", buffer)
          map("[[", "prev", buffer)
        end,
      })
    end,
  },
  -- TODO: mini.bufremove?
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
}
