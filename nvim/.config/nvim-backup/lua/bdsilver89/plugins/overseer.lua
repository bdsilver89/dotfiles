return {
  "stevearc/overseer.nvim",
  keys = {
    { "<leader>oR", "<cmd>OverseerRunCmd<cr>", desc = "Run Command" },
    { "<leader>oa", "<cmd>OverseerTaskAction<cr>", desc = "Task Action" },
    { "<leader>ob", "<cmd>OverseerBuild<cr>", desc = "Build" },
    { "<leader>oc", "<cmd>OverseerClose<cr>", desc = "Close" },
    { "<leader>od", "<cmd>OverseerDeleteBundle<cr>", desc = "Delete Bundle" },
    { "<leader>ol", "<cmd>OverseerLoadBundle<cr>", desc = "Load Bundle" },
    { "<leader>oo", "<cmd>OverseerOpen<cr>", desc = "Open" },
    { "<leader>oq", "<cmd>OverseerQuickAction<cr>", desc = "Quick Action" },
    { "<leader>or", "<cmd>OverseerRun<cr>", desc = "Run" },
    { "<leader>os", "<cmd>OverseerSaveBundle<cr>", desc = "Save Bundle" },
    { "<leader>ot", "<cmd>OverseerToggle<cr>", desc = "Toggle" },
  },
  opts = {
    strategy = "toggleterm",
  },
  config = true,
}
