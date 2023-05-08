return {
  {
    "nvim-neotest/neotest",
    event = "VeryLazy",
    dependencies = {
      "nvim-neotest/neotest-go",
      "alfaix/neotest-gtest",
      "nvim-neotest/neotest-python",
      "rouge8/neotest-rust",
    },
    config = function(_, opts)
      require("neotest").setup({
        adapters = {
          require("neotest-go"),
          require("neotest-gtest"),
          require("neotest-python"),
          require("neotest-rust"),
        }
      })
    end,
  },
}
