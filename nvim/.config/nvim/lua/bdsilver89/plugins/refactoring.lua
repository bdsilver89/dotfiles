return {
  "ThePrimeagen/refactoring.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  keys = {
    {
      "<leader>rs",
      function()
        require("telescope").extensions.refactoring.refactors()
      end,
      mode = { "n", "v" },
      desc = "Refactor",
    },
    {
      "<leader>ri",
      function()
        require("refactoring").refactor("Inline Variable")
      end,
      mode = { "n", "v" },
      desc = "Inline Variable",
    },
    {
      "<leader>rb",
      function()
        require("refactoring").refactor("Extract Block")
      end,
      mode = { "n" },
      desc = "Extract Block",
    },
    {
      "<leader>rf",
      function()
        require("refactoring").refactor("Extract Block To File")
      end,
      mode = { "n" },
      desc = "Extract Block To File",
    },
    {
      "<leader>rP",
      function()
        require("refactoring").debug.printf({ below = false })
      end,
      mode = { "n" },
      desc = "Debug Print",
    },
    {
      "<leader>rp",
      function()
        require("refactoring").debug.print_var({ normal = true })
      end,
      mode = { "n" },
      desc = "Debug Print Variable",
    },
    {
      "<leader>rc",
      function()
        require("refactoring").debug.cleanup({})
      end,
      mode = { "n" },
      desc = "Debug Cleanup",
    },
    {
      "<leader>rf",
      function()
        require("refactoring").refactor("Extract Function")
      end,
      mode = { "v" },
      desc = "Extract Function",
    },
    {
      "<leader>rF",
      function()
        require("refactoring").refactor("Extract Function To File")
      end,
      mode = { "v" },
      desc = "Extract Function To File",
    },
    {
      "<leader>rx",
      function()
        require("refactoring").refactor("Extract Variable")
      end,
      mode = { "v" },
      desc = "Extract Variable",
    },
    {
      "<leader>rp",
      function()
        require("refactoring").debug.print_var({})
      end,
      mode = { "v" },
      desc = "Debug Print Variable",
    },
  },
  opts = {},
  config = function(_, opts)
    require("refactoring").setup(opts)
    require("telescope").load_extension("refactoring")
  end,
}
