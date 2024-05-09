return {
  -- general git commands
  {
    "tpope/vim-fugitive",
    lazy = false,
    enabled = vim.fn.executable("git") == 1,
    keys = {
      { "<leader>gm", "<cmd>Git<cr>", desc = "Status" },
      { "<leader>gb", "<cmd>Git blame<cr>", desc = "Blame" },
      { "<leader>gc", "<cmd>Git commit<cr>", desc = "Commit" },
    }
  },

  {
    "sindrets/diffview.nvim",
    enabled = vim.fn.executable("git") == 1,
    cmd = {
      "DiffviewClose",
      "DiffviewFileHistory",
      "DiffviewOpen",
      "DiffviewToggleFiles",
      "DiffviewFocusFiles",
      "DiffviewRefresh",
    }
  },

  -- git highlights
  {
    "lewis6991/gitsigns.nvim",
    cmd = "Gitsigns",
    event = { "BufReadPost", "BufNewFile" },
    enabled = vim.fn.executable("git") == 1,
    opts = function()
      local Utils = require("bdsilver89.utils")

      return {
        signs = {
          add = { text = Utils.ui.get_icon("gitsigns", "Add") },
          change = { text = Utils.ui.get_icon("gitsigns", "Change") },
          delete = { text = Utils.ui.get_icon("gitsigns", "Delete") },
          topdelete = { text = Utils.ui.get_icon("gitsigns", "TopDelete") },
          changedelete = { text = Utils.ui.get_icon("gitsigns", "ChangeDelete") },
          untracked = { text = Utils.ui.get_icon("gitsigns", "Untracked") },
        },
        on_attach = function(buffer)
          local gs = package.loaded.gitsigns

          local function map(mode, l, r, desc)
            vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
          end

          -- stylua: ignore start
          map("n", "]h", gs.next_hunk, "Next Hunk")
          map("n", "[h", gs.prev_hunk, "Prev Hunk")
          map({ "n", "v" }, "<leader>ghs", ":Gitsigns stage_hunk<CR>", "Stage Hunk")
          map({ "n", "v" }, "<leader>ghr", ":Gitsigns reset_hunk<CR>", "Reset Hunk")
          map("n", "<leader>ghS", gs.stage_buffer, "Stage Buffer")
          map("n", "<leader>ghu", gs.undo_stage_hunk, "Undo Stage Hunk")
          map("n", "<leader>ghR", gs.reset_buffer, "Reset Buffer")
          map("n", "<leader>ghp", gs.preview_hunk_inline, "Preview Hunk Inline")
          map("n", "<leader>ghb", function() gs.blame_line({ full = true }) end, "Blame Line")
          map("n", "<leader>ghd", gs.diffthis, "Diff This")
          map("n", "<leader>ghD", function() gs.diffthis("~") end, "Diff This ~")
          map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk")
        end,
      }
    end,
  },

  -- git worktree support
  {
    "ThePrimeagen/git-worktree.nvim",
    -- TODO: enable AFTER deciding on sane keymaps here
    enabled = false,
  },
}
