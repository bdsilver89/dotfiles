return {
  {
    "lewis6991/gitsigns.nvim",
    event = "LazyFile",
    opts = {
      signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
        untracked = { text = "▎" },
      },
      on_attach = function(buffer)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
        end

        -- stylua: ignore start
        map("n", "]h", gs.next_hunk, "Next hunk")
        map("n", "[h", gs.prev_hunk, "Next hunk")
        map({ "n", "v" }, "<leader>ghs", gs.stage_hunk, "Stage hunk")
        map({ "n", "v" }, "<leader>ghr", gs.reset_hunk, "Reset hunk")
        map("n", "<leader>ghS", gs.stage_buffer, "Stage buffer")
        map("n", "<leader>ghu", gs.undo_stage_hunk, "Undo stage hunk")
        map("n", "<leader>ghR", gs.reset_buffer, "Reset buffer")
        map("n", "<leader>ghp", gs.preview_hunk, "Preview hunk")
        map("n", "<leader>ghb", function() gs.blame_line({ full = true }) end, "Blame line")
        map("n", "<leader>ghd", gs.diffthis, "Diff this")
        map("n", "<leader>ghD", function() gs.diffthis("~") end, "Diff this ~")
        map("n", "<leader>gtd", gs.toggle_deleted, "Toggle deleted")
        map("n", "<leader>gtb", gs.toggle_current_line_blame, "Toggle current line blame")

        map({ "o", "x" }, "ih", ":<c-u>Gitsigns select_hunk<cr>", "Gitsigns select hunk")
        -- stylua: ignore end
      end,
    },
  },
  {
    "tpope/vim-fugitive",
    event = "LazyFile",
  },
  {
    "sindrets/diffview.nvim",
    enabled = false,
    cmd = { "DiffviewOpen", "DiffviewFileHistory" },
  },
}
