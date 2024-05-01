return {
  {
    "folke/todo-comments.nvim",
    cmd = {
      "TodoTrouble",
      "TodoTelescope",
      "TodoLocList",
      "TodoQuickFix",
    },
    dependencies = {
      { "nvim-lua/plenary.nvim", lazy = true },
    },
    keys = {
      { "]t", function() require("todo-comments").jump_next() end, desc = "Next todo comment" },
      { "[t", function() require("todo-comments").jump_prev() end, desc = "Previous todo comment" },
      { "<leader>xt", "<cmd>TodoTrouble<cr>", desc = "Todo" },
      { "<leader>st", "<cmd>TodoTelescope<cr>", desc = "Todo" },
    },
    opts = {},
  },
}
