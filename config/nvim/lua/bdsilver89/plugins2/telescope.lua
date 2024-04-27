return {
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    version = false,
    dependencies = {},
    keys = {},
    opts = function()
      return {
        defaults = {
          sorting_strategy = "ascending",
          layout_config = {
            prompt_position = "top",
          },
        },
        extensions = {},
        mappings = {},
      }
    end,
    config = function(_, opts)
      require("telescope").setup(opts)
    end,
  }
}
