return {
  {
    "danymat/neogen",
    opts = {
      enabled = true,
      snippet_engine = "luasnip",
      languages = {
        lua = {
          template = {
            annoation_convention = "ldoc",
          },
        },
      },
    },
    -- stylua: ignore
    keys = {
      { "<leader>cgd", function() require("neogen").generate({}) end,                   desc = "Annotation" },
      { "<leader>cgc", function() require("neogen").generate({ type = "class" }) end, desc = "Class" },
      { "<leader>cgf", function() require("neogen").generate({ type = "func" }) end,  desc = "Function" },
      { "<leader>cgt", function() require("neogen").generate({ type = "type" }) end,  desc = "Type" },
    },
  },
  -- {
  --   "mbbill/undotree",
  --   keys = {
  --     { "<leader>cu", "<cmd>UndotreeToggle<cr>", desc = "Undotree" },
  --   },
  --   config = true,
  -- },
}
