local add = require("pack").add

add({
  {
    src = "nvim-lua/plenary.nvim",
    setup = false,
  },
  {
    src = "pwntester/octo.nvim",
    opts = {
      picker = "fzf-lua",
    },
    on_setup = function()
      vim.keymap.set("n", "<leader>gi", "<cmd>Octo issue list<cr>", { desc = "List Issues" })
      vim.keymap.set("n", "<leader>gI", "<cmd>Octo issue search<cr>", { desc = "Search Issues" })
      vim.keymap.set("n", "<leader>gp", "<cmd>Octo pr list<cr>", { desc = "List PRs" })
      vim.keymap.set("n", "<leader>gP", "<cmd>Octo pr search<cr>", { desc = "Search PRs" })
      vim.keymap.set("n", "<leader>gr", "<cmd>Octo repo list<cr>", { desc = "List Repos" })
      vim.keymap.set("n", "<leader>gS", "<cmd>Octo search<cr>", { desc = "Search" })
    end,
  },
})
