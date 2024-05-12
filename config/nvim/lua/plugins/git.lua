return {
  -- git commands
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",
      "nvim-telescope/telescope.nvim",
    },
    cmd = "Neogit",
    keys = {
      { "<leader>gs", "<cmd>Neogit<cr>",        desc = "Status" },
      { "<leader>gc", "<cmd>Neogit commit<cr>", desc = "Commit" },
      { "<leader>gl", "<cmd>Neogit pull<cr>",   desc = "Pull" },
      { "<leader>gp", "<cmd>Neogit push<cr>",   desc = "Push" },
    },
    opts = {},
  },

  -- mostly used to suplment neogit (e.g. for git blame)
  {
    "tpope/vim-fugitive",
    lazy = false,
    keys = {
      { "<leader>gB", "<cmd>G blame<cr>", desc = "Blame" },
    },
  },

  -- git highlights
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      -- signs = {
      --   add = { text = '+' },
      --   change = { text = '~' },
      --   delete = { text = '_' },
      --   topdelete = { text = '‾' },
      --   changedelete = { text = '~' },
      -- },
      current_line_blame = true,
      on_attach = function(buffer)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
        end

        map("n", "]c", function()
          if vim.wo.diff then
            vim.cmd.normal({ "]c", bang = true })
          else
            gitsigns.next_hunk()
          end
        end, "Next hunk")

        map("n", "[c", function()
          if vim.wo.diff then
            vim.cmd.normal({ "[c", bang = true })
          else
            gitsigns.prev_hunk()
          end
        end, "Prev hunk")

        map({ "n", "v" }, "<leader>hs", gs.stage_hunk, "Stage hunk")
        map({ "n", "v" }, "<leader>hr", gs.reset_hunk, "Reset hunk")
        map("n", "<leader>hS", gs.stage_buffer, "Stage buffer")
        map("n", "<leader>ha", gs.stage_hunk, "Stage hunk")
        map("n", "<leader>hu", gs.undo_stage_hunk, "Undo stage hunk")
        map("n", "<leader>hR", gs.reset_buffer, "Reset buffer")
        map("n", "<leader>hp", gs.preview_hunk, "Reset hunk")
        map("n", "<leader>ub", gs.toggle_current_line_blame, "Toggle git line blame")
        map("n", "<leader>hd", gs.diffthis, "Diff this")
        map("n", "<leader>hD", function() gs.diffthis("~") end, "Diff this ~")
        map("n", "<leader>ud", gs.toggle_deleted, "Toggle git deleted")
        map({ "o", "x" }, "ih", ":<c-u>Gitsigns select_hunk", "Select git hunk")
      end
    },
  },

  -- git worktrees
  {
    "ThePrimeagen/git-worktree.nvim",
    opts = {},
  }
}
