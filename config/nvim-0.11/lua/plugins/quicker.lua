return {
  "stevearc/quicker.nvim",
  event = "VeryLazy",
  -- stylua: ignore
  keys = {
    { "<leader>xq", function() require("quicker").toggle() end, desc = "Toggle quickfix" },
    { "<leader>xl", function() require("quicker").toggle({ loclist = true }) end, desc = "Toggle loclist" },
    {
      "<leader>xd",
      function()
        local quicker = require("quicker")
        if quicker.is_open() then
          quicker.close()
        else
          vim.diagnostic.setqflist()
        end
      end,
      desc = "Toggle diagnostics",
    },
    {
      ">",
      function()
        require("quicker").expand({ bufer = 2, after = 2, add_to_existing = true })
      end,
      desc = "Expand quickfix context",
    },
    {
      "<",
      function()
        require("quicker").collapse()
      end,
      desc = "Collapse quickfix context",
    },
  },
  opts = {},
}
