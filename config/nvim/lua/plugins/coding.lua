return {
  {
    "danymat/neogen",
    dependencies = {
      {
        "folke/which-key.nvim",
        opts = {
          defaults = {
            ["<leader>cg"] = "+gendoc",
          },
        },
      },
    },
    opts = {
      enabled = true,
      snippet_engine = "luasnip",
      languages = {
        lua = {
          template = {
            annotation_convention = "ldoc",
          },
        },
      },
    },
    -- stylua: ignore
    keys = {
      { "<leader>cgd", function() require("neogen").generate({}) end, desc = "Annotation" },
      { "<leader>cgc", function() require("neogen").generate({type= "class"}) end, desc = "Class" },
      { "<leader>cgf", function() require("neogen").generate({type = "func"}) end, desc = "Function" },
      { "<leader>cgt", function() require("neogen").generate({type = "type"}) end, desc = "Type" },
    },
  },

  -- incremental rename
  {
    "smjonas/inc-rename.nvim",
    cmd = "IncRename",
    config = true,
  },
}
