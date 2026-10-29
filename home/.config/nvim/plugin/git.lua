vim.pack.add({
  "https://github.com/lewis6991/gitsigns.nvim",
  "https://github.com/tpope/vim-fugitive",
})

require("gitsigns").setup({
  current_line_blame = true,
  on_attach = function(bufnr)
    local gs = package.loaded.gitsigns

    local function map(mode, lhs, rhs, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, lhs, rhs, opts)
    end

    map("n", "[c", function()
      if vim.wo.diff then
        vim.cmd.normal({ "[c", bang = true })
      else
        gs.nav_hunk("next")
      end
    end)

    map("n", "]c", function()
      if vim.wo.diff then
        vim.cmd.normal({ "]c", bang = true })
      else
        gs.nav_hunk("prev")
      end
    end)

    map("n", "<leader>hs", gs.stage_hunk)
    map("n", "<leader>he", gs.reset_hunk)
    map("v", "<leader>hs", function()
      gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
    end)
    map("v", "<leader>hr", function()
      gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
    end)

    map("n", "<leader>hS", gs.stage_buffer)
    map("n", "<leader>hR", gs.reset_buffer)
    map("n", "<leader>hp", gs.preview_hunk)
    map("n", "<leader>hi", gs.preview_hunk_inline)

    map("n", "<leader>hb", function()
      gs.blame_line({ full = true })
    end)
    map("n", "<leader>hB", function()
      gs.blame()
    end)

    map("n", "<leader>hd", gs.diffthis)
    map("n", "<leader>hD", function()
      gs.diffthis("~")
    end)

    map("n", "<leader>hq", gs.setqflist)
    map("n", "<leader>hQ", function()
      gs.setqflist("all")
    end)

    map({ "o", "x" }, "ih", gs.select_hunk)
  end,
})
