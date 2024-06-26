return {
  {
    "NeogitOrg/neogit",
    cmd = "Neogit",
    opts = {},
  },

  {
    "lewis6991/gitsigns.nvim",
    event = "LazyFile",
    config = function()
      local Icons = require("config.icons")
      require("gitsigns").setup({
        signs = {
          add = { text = Icons.get_icon("gitsigns", "Add") },
          change = { text = Icons.get_icon("gitsigns", "Change") },
          delete = { text = Icons.get_icon("gitsigns", "Delete") },
          topdelete = { text = Icons.get_icon("gitsigns", "TopDelete") },
          changedelete = { text = Icons.get_icon("gitsigns", "ChangeDelete") },
          untracked = { text = Icons.get_icon("gitsigns", "Untracked") },
        },
        current_line_blame = true,
        on_attach = function(buffer)
          local gs = package.loaded.gitsigns

          local function map(mode, l, r, desc)
            vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
          end

          -- stylua: ignore start
          map("n", "]h", function() gs.nav_hunk("next") end, "Next hunk")
          map("n", "[h", function() gs.nav_hunk("prev") end, "Prev hunk")
          map("n", "]H", function() gs.nav_hunk("last") end, "Last hunk")
          map("n", "[H", function() gs.nav_hunk("first") end, "First hunk")
          map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns select hunk")
          map("n", "<leader>ugb", function() gs.toggle_current_line_blame() end, "Toggle git line blame")
        end,
      })
    end,
  },
}
