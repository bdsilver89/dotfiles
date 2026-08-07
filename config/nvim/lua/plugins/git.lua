vim.pack.add({
  "https://github.com/lewis6991/gitsigns.nvim",
})

require("gitsigns").setup({
  -- current_line_blame = true,
  on_attach = function(bufnr)
    local gs = require("gitsigns")

    local map = function(mode, l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end

    map("n", "]c", function()
      if vim.wo.diff then
        vim.cmd.normal({ "]c", bang = true })
      else
        gs.nav_hunk("next")
      end
    end, { desc = "Next change" })

    map("n", "[c", function()
      if vim.wo.diff then
        vim.cmd.normal({ "[c", bang = true })
      else
        gs.nav_hunk("prev")
      end
    end, { desc = "Prev change" })

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
    end, { desc = "Blame line" })
    map("n", "<leader>hd", gs.diffthis, { desc = "Diff aginst index" })
    map("n", "<leader>hD", function()
      gs.diffthis("@")
    end, { desc = "Diff against last commit" })
    map("n", "<leader>hQ", function()
      gs.setqflist("all")
    end, { desc = "Hunk quickfix list repo changes" })
    map("n", "<leader>hq", gs.setqflist, { desc = "Hunk quickfix list file changes" })

    map("n", "<leader>ub", gs.toggle_current_line_blame, { desc = "Toggle git blame" })
    map("n", "<leader>uw", gs.toggle_word_diff, { desc = "Toggle word diff" })

    map({ "o", "x" }, "ih", gs.select_hunk)
  end,
})
