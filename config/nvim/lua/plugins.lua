vim.cmd.packadd("nvim.difftool")

require("vim._core.ui2").enable({
  enable = true,
})

vim.pack.add({
  "https://github.com/nvim-treesitter/nvim-treesitter",
  "https://github.com/nvim-treesitter/nvim-treesitter-textobjects",
  "https://github.com/mason-org/mason.nvim",
  "https://github.com/tpope/vim-sleuth",
  "https://github.com/tpope/vim-fugitive",
  "https://github.com/lewis6991/gitsigns.nvim",
  "https://github.com/stevearc/oil.nvim",
  "https://github.com/ibhagwan/fzf-lua",
})

require("nvim-treesitter-textobjects").setup({
  select = {
    lookahead = true,
  },
  move = {
    enable = true,
    set_jumps = true,
  },
})

require("mason").setup()
require("oil").setup()
require("fzf-lua").setup()
require("gitsigns").setup({
  current_line_blame = true,
  on_attach = function(buf)
    local gs = require("gitsigns")

    local map = function(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = buf, desc = desc })
    end

    -- stylua: ignore start
    map("n", "]c", function()
      if vim.wo.diff then
        vim.cmd.normal("]c", { bang = true })
      else
        gs.nav_hunk("next")
      end
    end, "Next Hunk")
    map("n", "[c", function()
      if vim.wo.diff then
        vim.cmd.normal("]c", { bang = true })
      else
        gs.nav_hunk("prev")
      end
    end, "Prev Hunk")

    map("v", "<leader>hs", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Stage Hunk")
    map("v", "<leader>hr", function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Reset Hunk")

    map("n", "<leader>hs", gs.stage_hunk, "Stage Hunk")
    map("n", "<leader>hr", gs.reset_hunk, "Reset Hunk")
    map("n", "<leader>hS", gs.stage_buffer, "Stage Buffer")
    map("n", "<leader>hR", gs.reset_buffer, "Reset Buffer")
    map("n", "<leader>hp", gs.preview_hunk, "Preview Hunk")
    map("n", "<leader>hi", gs.preview_hunk_inline, "Preview Hunk Inline")
    map("n", "<leader>hb", function() gs.blame_line({ full = true }) end, "Blame Line")
    map("n", "<leader>hd", gs.diffthis, "Diff Against Index")
    map("n", "<leader>hD", function() gs.diffthis("@") end, "Diff Agsint HEAD")
    map("n", "<leader>hQ", function() gs.setqflist("all") end, "Send to Quickfix")

    map("n", "<leader>ub", gs.toggle_current_line_blame, "Toggle Blame Line")

    map({ "o", "x" }, "ih", gs.select_hunk, "Select Hunk")
    -- stylua: ignore end
  end,
})
