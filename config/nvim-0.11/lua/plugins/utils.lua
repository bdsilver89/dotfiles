return {
  -- general lua utilities
  "nvim-lua/plenary.nvim",

  -- schema utilities for json and yaml lsp
  {
    "b0o/SchemaStore.nvim",
    enabled = false, -- FIXME: disabled until native snippet integration works with this
    lazy = true,
    version = false,
  },

  -- markdown rendering
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown", "norg", "rmd", "org" },
    opts = {
      code = {
        sign = true,
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
