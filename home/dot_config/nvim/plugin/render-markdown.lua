local add_on_filetype = require("pack").add_on_filetype

add_on_filetype({ "markdown" }, {
  {
    src = "MeanderingProgrammer/render-markdown.nvim",
    opts = {
      code = {
        sign = false,
        width = "block",
        right_pad = 1,
      },
      heading = {
        sign = false,
        icons = {},
      },
      checkbox = {
        enabled = false,
      },
    },
  },
})
