return {
  {
    "NeogitOrg/neogit",
    dependencies = {
      "sindrets/diffview.nvim",
    },
    cmd = "Neogit",
    keys = {
      { "<leader>gs", "<cmd>Neogit<cr>", desc = "Git status" },
      { "<leader>gc", "<cmd>Neogit commit<cr>", desc = "Git commit" },
      { "<leader>gp", "<cmd>Neogit pull<cr>", desc = "Git pull" },
      { "<leader>gP", "<cmd>Neogit push<cr>", desc = "Git push" },
    },
    opts = {
      integrations = {
        diffview = true,
      },
      graph_style = "unicode",
    },
  },

  {
    "tpope/vim-fugitive",
    event = { "BufReadPost", "BufNewFile" },
  },

  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = function()
      local function sign(glyph, text)
        return vim.g.enable_icons and glyph or text
      end

      return {
        signs = {
          add = { text = sign("▎", "+") },
          change = { text = sign("▎", "~") },
          delete = { text = sign("", "_") },
          topdelete = { text = sign("", "‾") },
          changedelete = { text = sign("▎", "~") },
          untracked = { text = sign("▎", "~") },
        },
        signs_staged = {
          add = { text = sign("▎", "+") },
          change = { text = sign("▎", "~") },
          delete = { text = sign("", "_") },
          topdelete = { text = sign("", "‾") },
          changedelete = { text = sign("▎", "~") },
          untracked = { text = sign("▎", "~") },
        },
        signcolumn = true,
        current_line_blame = false,
        current_line_blame_opts = {
          virt_text = true,
          virt_text_pos = "right_align", -- 'eol' | 'overlay' | 'right_align'
          ignore_whitespace = false,
        },
        preview_config = {
          border = "rounded",
        },
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
          map("n", "<leader>ub", gs.toggle_current_line_blame, "Toggle current line blame")
          map("n", "<leader>ghd", gs.diffthis, "Diff this")
          map("n", "<leader>ghD", function() gs.diffthis("~") end, "Diff this ~")
          map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns select hunk")
        end,
      }
    end,
  },
}
