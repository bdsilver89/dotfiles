return {
  -- "tpope/vim-fugitive",

  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",
      "nvim-telescope/telescope.nvim",
    },
  },

  -- gitsigns
  {
    "lewis6991/gitsigns.nvim",
    opts = function()
      local function sign_text(text, nerd_text)
        if vim.g.have_nerd_font then
          return nerd_text
        else
          return text
        end
      end

      return {
        signs = {
          add = { text = sign_text("+", "▎") },
          change = { text = sign_text("~", "▎") },
          delete = { text = sign_text("_", "") },
          topdelete = { text = sign_text("‾", "") },
          changedelete = { text = sign_text("~", "▎") },
          untracked = { text = sign_text("u", "▎") },
        },
        on_attach = function(buffer)
          local gs = package.loaded.gitsigns

          local function map(mode, l, r, desc)
            vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
          end

          -- stylua: ignore
          map("n", "]h", gs.next_hunk, "Next hunk")
          map("n", "[h", gs.prev_hunk, "Prev hunk")
          map({ "n", "v" }, "<leader>ghs", ":Gitsigns stage_hunk<cr>", "Stage hunk")
          map({ "n", "v" }, "<leader>ghr", ":Gitsigns reset_hunk<cr>", "Reset hunk")
          map("n", "<leader>ghS", gs.stage_buffer, "Stage buffer")
          map("n", "<leader>ghu", gs.undo_stage_hunk, "Undo stage hunk")
          map("n", "<leader>ghR", gs.reset_buffer, "Reset buffer")
          map("n", "<leader>ghp", gs.preview_hunk_inline, "Preview hunk inline")
          map("n", "<leader>ghP", gs.preview_hunk, "Preview hunk")
          map("n", "<leader>ghb", function() gs.blame_line({ full = true }) end, "Blame Line")
          map("n", "<leader>ghd", gs.diffthis, "Diff This")
          map("n", "<leader>ghD", function() gs.diffthis("~") end, "Diff This ~")
          map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk")
        end,
      }
    end,
  },
}
