return {
  {
    "tpope/vim-fugitive",
    lazy = false,
    keys = {
      { "<leader>gs", "<cmd>Git<cr>", desc = "Git Status" },
      -- { "<leader>gd", "<cmd>Gdiff<cr>", desc = "Git Diff" },
      { "<leader>gd", "<cmd>Gvdiffsplit<cr>", desc = "Git Diff" },
      { "<leader>gl", "<cmd>Git log<cr>", desc = "Git Log" },
      { "<leader>gL", "<cmd>Gclog<cr>", desc = "Git Log Quickfix" },
      { "<leader>gf", "<cmd>Git log -- %<cr>", desc = "Git File Log" },
      { "<leader>gF", "<cmd>0Gclog<cr>", desc = "Git File Log Quickfix" },
    },
  },

  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      current_line_blame = true,
      on_attach = function(buffer)
        local gs = require("gitsigns")

        local function map(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = buffer, desc = desc })
        end

        -- Navigation
        map("n", "]c", function()
          if vim.wo.diff then
            vim.cmd.normal({ "]c", bang = true })
          else
            gs.nav_hunk("next")
          end
        end, "Next Hunk")

        map("n", "[c", function()
          if vim.wo.diff then
            vim.cmd.normal({ "[c", bang = true })
          else
            gs.nav_hunk("prev")
          end
        end, "Prev Hunk")

        map("n", "]C", function()
          gs.nav_hunk("last")
        end, "Last Hunk")

        map("n", "[C", function()
          gs.nav_hunk("first")
        end, "First Hunk")

        -- Actions
        map("n", "<leader>hs", gs.stage_hunk, "Stage Hunk")
        map("n", "<leader>hr", gs.reset_hunk, "Reset Hunk")

        map("v", "<leader>hs", function()
          gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, "Stage Hunk")

        map("v", "<leader>hr", function()
          gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, "Reset Hunk")

        map("n", "<leader>hS", gs.stage_buffer, "Stage Buffer")
        map("n", "<leader>hR", gs.reset_buffer, "Reset Buffer")
        map("n", "<leader>hp", gs.preview_hunk, "Preview Hunk")
        map("n", "<leader>hi", gs.preview_hunk_inline, "Preview Hunk Inline")

        map("n", "<leader>hb", function()
          gs.blame_line({ full = true })
        end, "Blame Line")

        map("n", "<leader>hd", gs.diffthis, "Diff This")

        map("n", "<leader>hQ", function()
          gs.setqflist("all")
        end, "Set Quickfix All")

        map("n", "<leader>hq", gs.setqflist, "Set Quickfix")

        map("n", "<leader>hD", function()
          gs.diffthis("~")
        end, "Diff This ~")

        -- Toggles
        map("n", "<leader>tb", gs.toggle_current_line_blame, "Toggle Git Line Blame")

        -- Text object
        map({ "o", "x" }, "ih", gs.select_hunk)
      end,
    },
  },
}
