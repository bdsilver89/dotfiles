return {
  {
    "mfussenegger/nvim-dap",
    -- stylua: ignore
    keys = {
      -- the original keymaps bother me, step over seems more common then step out...
      { "<leader>do", function() require("dap").step_over() end, desc = "Step Over" },
      { "<leader>dO", function() require("dap").step_out() end, desc = "Step Out" },
    }
,
  },
}
