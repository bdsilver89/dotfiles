return {
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    -- stylua: ignore
    keys = {
      { "<leader>qs", function() require("persistence").load() end, desc = "Restore session" },
      { "<leader>ql", function() require("persistence").load({ last = true }) end, desc = "Restore last session" },
      { "<leader>qd", function() require("persistence").stop() end, desc = "Don't save current sesssion" },
    },
    opts = {
      options = vim.opt.sessionoptions:get(),
    },
  },
}
