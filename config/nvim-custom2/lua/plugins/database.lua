return {
  {
    "kndndrj/nvim-dbee",
    dependencies = {
      "MunifTanjim/nui.nvim",
    },
    keys = {
      {
        "<leader>D",
        function()
          require("dbee").toggle()
        end,
        desc = "Database",
      },
    },
    build = function()
      require("dbee").install()
    end,
    opts = {},
  },
}
