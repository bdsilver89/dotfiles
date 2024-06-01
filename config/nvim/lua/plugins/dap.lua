return {
  {
    "mfussenegger/nvim-dap",
    -- stylua: ignore
    keys = {
      -- reverse the step_over/step_out keys
      -- 'o' is easier than 'O' to press, and I find stepping over to be more frequently used
      { "<leader>do", function() require("dap").step_over() end, desc = "Step Over" },
      { "<leader>dO", function() require("dap").step_out() end, desc = "Step Out" },
    },
  },
}
