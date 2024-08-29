return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "git_config", "gitcommit", "git_rebase", "gitignore", "gitattributes" } },
  },

  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      { "petertriho/cmp-git", opts = {} },
    },
    opts = function(_, opts)
      table.insert(opts.sources, { name = "git" })
    end,
  },

  -- git editor
  -- {
  --   "tpope/vim-fugitive",
  --   lazy = false,
  --   keys = {
  --     { "<leader>gs", "<cmd>Git<cr>",       desc = "Git status" },
  --   }
  -- },

  -- advanced git editor
  {
    "NeogitOrg/neogit",
    cmd = "Neogit",
    opts = {},
    keys = {
      { "<leader>gs", "<cmd>Neogit<cr>", desc = "Git status (Neogit)" },
    },
  },

  {
    -- dir = "~/dev/projects/git2.nvim",
    "bdsilver89/git2.nvim",
    name = "git2",
    cmd = { "Git2" },
    enabled = vim.fn.executable("cmake") == 1,
    build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build",
    opts = {},
  },

  -- git signs integration
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
        untracked = { text = "▎" },
      },
      signs_staged = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
      },
      current_line_blame = true,
      on_attach = function(buffer)
        local gs = package.loaded.gitsigns

        local function map(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { desc = desc, buffer = buffer })
        end

        -- stylua: ignore start
        map("n", "]h", function()
          if vim.wo.diff then
            vim.cmd.normal({ "]c", bang = true })
          else
            gs.nav_hunk("next")
          end
        end, "Next hunk")
        map("n", "[h", function()
          if vim.wo.diff then
            vim.cmd.normal({ "[c", bang = true })
          else
            gs.nav_hunk("prev")
          end
        end, "Prev hunk")
        map("n", "]H", function() gs.nav_hunk("last") end, "Last hunk")
        map("n", "[H", function() gs.nav_hunk("first") end, "First hunk")
        map({ "n", "v" }, "<leader>ghs", ":Gitsigns stage_hunk<cr>", "Stage hunk")
        map({ "n", "v" }, "<leader>ghr", ":Gitsigns reset_hunk<cr>", "Reset hunk")
        map("n", "<leader>ghS", gs.stage_buffer, "Stage buffer")
        map("n", "<leader>ghu", gs.undo_stage_hunk, "Undo stage hunk")
        map("n", "<leader>ghR", gs.reset_buffer, "Reset buffer")
        map("n", "<leader>ghp", gs.preview_hunk_inline, "Preview hunk inline")
        map("n", "<leader>ghb", function() gs.blame_line({ full = true }) end, "Blame line")
        map("n", "<leader>ghB", function() gs.blame_line() end, "Blame buffer")
        map("n", "<leader>ghd", gs.diffthis, "Diff this")
        map("n", "<leader>ghD", function() gs.diffthis("~") end, "Diff this ~")
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns select hunk")
        map("n", "<leader>gb", "<cmd>Git blame<cr>", "Blame")

        require("config.utils").toggle("<leader>ugb", {
          name = "Git Line Blame",
          get = function()
            return require("gitsigns.config").config.current_line_blame
          end,
          set = function(state)
            require("gitsigns").toggle_current_line_blame(state)
          end
        })
      end,
    },
  },
}
