return {
  -- git commands
  {
    "tpope/vim-fugitive",
    lazy = false,
  },

  -- git highlights and hunk commands
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = function()
      local function nerd_sign(text, nerd_text)
        if vim.g.have_nerd_font then
          return nerd_sign
        end
        return text
      end
      return {
        signs = {
          add = { text = nerd_sign("+", "▎") },
          change = { text = nerd_sign("~","▎") },
          delete = { text = nerd_sign("_","") },
          topdelete = { text = nerd_sign("‾","") },
          changedelete = { text = nerd_sign("~","▎") },
          untracked = { text = nerd_sign("u","▎") },
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

  -- git worktrees
  {
    "ThePrimeagen/git-worktree.nvim",
    enabled = false,
    opts = {},
  },
}
