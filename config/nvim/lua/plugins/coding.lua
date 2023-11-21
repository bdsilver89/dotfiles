return {
  {
    "danymat/neogen",
    keys = {
      {
        "<leader>cc",
        function()
          require("neogen").generate({})
        end,
        desc = "Neogen comment",
      },
    },
    opts = {
      snippet_engine = "luasnip",
    },
  },
}
