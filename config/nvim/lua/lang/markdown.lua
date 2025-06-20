return {
  {
    "nvim-treesitter",
    opts = { ensure_installed = { "markdown", "markdown_inline" } },
  },

  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown", "norg", "rmd", "org", "avante", "codecompanion" },
    opts = {
      code = {
        sign = false,
        width = "block",
        right_pad = 1,
      },
      heading = {
        sign = true,
        icons = {},
      },
    },
  },
}
