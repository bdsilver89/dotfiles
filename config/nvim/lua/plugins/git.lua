local add = MiniDeps.add

add("tpope/vim-fugitive")
add("lewis6991/gitsigns.nvim")

require("gitsigns").setup({
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
    -- stylua: ignore start
    map("n", "<leader>gs", gs.stage_buffer, "Stage Buffer")
    map("n", "<leader>gr", gs.reset_buffer, "Reset Buffer")
    map("n", "<leader>ghp", gs.preview_hunk_inline, "Preview Hunk Inline")
    map("n", "<leader>ghb", function() gs.blame_line({ full = true }) end, "Blame")
    map("n", "<leader>gB", gs.blame, "Blame")
    map("n", "<leader>ghd", gs.diffthis, "Diff This")
    map("n", "<leader>ghD", function() gs.diffthis("~") end, "Diff This ~")
    map("n", "<leader>ghQ", function() gs.setqflist("all") end, "Set Quickfix All")
    map("n", "<leader>ghq", gs.setqflist, "Set Quickfix")
    map("n", "<leader>ghs", gs.stage_hunk, "Stage Hunk")
    map("n", "<leader>ghr", gs.reset_hunk, "Reset Hunk")
    map("v", "<leader>ghs", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Stage Hunk")
    map("v", "<leader>ghr", function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Reset Hunk")
    -- stylua: ignore end

    -- Toggles
    map("n", "<leader>tb", gs.toggle_current_line_blame, "Toggle Git Line Blame")

    -- Text object
    map({ "o", "x" }, "ih", gs.select_hunk)
  end,
})
