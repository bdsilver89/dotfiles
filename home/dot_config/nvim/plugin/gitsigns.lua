local add_on_event = require("pack").add_on_event

-- local solid_bar = require("icons").misc.vertical_bar
-- local dashed_bar = require("icons").misc.dashed_bar

add_on_event({ "BufReadPre", "BufNewFile" }, {
  {
    src = "lewis6991/gitsigns.nvim",
    opts = {
      -- signs = {
      --   add = { text = solid_bar },
      --   untracked = { text = solid_bar },
      --   change = { text = solid_bar },
      --   delete = { text = solid_bar },
      --   topdelete = { text = solid_bar },
      --   changedelete = { text = solid_bar },
      -- },
      -- signs_staged = {
      --   add = { text = dashed_bar },
      --   untracked = { text = dashed_bar },
      --   change = { text = dashed_bar },
      --   delete = { text = dashed_bar },
      --   topdelete = { text = dashed_bar },
      --   changedelete = { text = dashed_bar },
      -- },
      current_line_blame = true,
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        local function map(mode, lhs, rhs, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, lhs, rhs, opts)
        end

        map("n", "]c", function()
          if vim.wo.diff then
            vim.cmd.normal("]c", { bang = true })
          else
            gs.nav_hunk("next")
          end
        end, { desc = "Jump to next change " })

        map("n", "[c", function()
          if vim.wo.diff then
            vim.cmd.normal("[c", { bang = true })
          else
            gs.nav_hunk("prev")
          end
        end, { desc = "Jump to next change " })

        map("v", "<leader>hs", function()
          gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, { desc = "Stage hunk" })
        map("v", "<leader>hr", function()
          gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, { desc = "Reset hunk" })

        map("n", "<leader>hs", gs.stage_hunk, { desc = "Stage hunk" })
        map("n", "<leader>hr", gs.reset_hunk, { desc = "Reset hunk" })
        map("n", "<leader>hS", gs.stage_buffer, { desc = "Stage buffer" })
        map("n", "<leader>hR", gs.reset_buffer, { desc = "Reset buffer" })
        map("n", "<leader>hp", gs.preview_hunk, { desc = "Preview hunk" })
        map("n", "<leader>hi", gs.preview_hunk_inline, { desc = "Preview hunk inline" })
        map("n", "<leader>hb", function()
          gs.blame_line({ full = true })
        end, { desc = "Blame hunk" })
        map("n", "<leader>hB", function()
          gs.blame()
        end, { desc = "Blame" })
        map("n", "<leader>hd", gs.diffthis, { desc = "Diff against index" })
        map("n", "<leader>hD", function()
          gs.diffthis("@")
        end, { desc = "Diff against last commit" })
        map("n", "<leader>hq", gs.setqflist, { desc = "Hunk quickfix" })
        map("n", "<leader>hQ", function()
          gs.setqflist("all")
        end, { desc = "Hunk quickfix all" })

        map({ "o", "x" }, "ih", gs.select_hunk)
      end,
    },
  },
})
