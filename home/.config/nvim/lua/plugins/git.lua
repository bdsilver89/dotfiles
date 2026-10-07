require("gitsigns").setup({
  current_line_blame = true,
  on_attach = function(bufnr)
    local gs = require("gitsigns")

    local function map(lhs, rhs, desc)
      vim.keymap.set("n", lhs, rhs, {
        buffer = bufnr,
        desc = desc,
      })
    end

    map("]c", function()
      gs.nav_hunk("next")
    end, "Next Git hunk")

    map("[c", function()
      gs.nav_hunk("prev")
    end, "Previous Git hunk")

    map("<leader>gp", gs.preview_hunk, "Preview hunk")
    map("<leader>gb", gs.blame_line, "Blame line")
  end,
})
