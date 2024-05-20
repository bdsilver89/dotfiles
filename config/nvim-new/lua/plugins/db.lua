return {
  "tpope/vim-dadbod",
  "kristijanhusak/vim-dadbod-completion",
  "kristijanhusak/vim-dadbod-ui",
  {
    "kndndrj/nvim-dbee",
    enabled = false,
    dependencies = {
      "nui.nvim",
    },
    build = function()
      require("dbee").install()
    end,
    config = function()
      require("dbee").setup()
    end,
  }
}
