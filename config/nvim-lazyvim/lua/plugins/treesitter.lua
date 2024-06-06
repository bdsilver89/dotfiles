return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, _)
      require("nvim-treesitter.install").prefer_git = true
    end,
  },
}
