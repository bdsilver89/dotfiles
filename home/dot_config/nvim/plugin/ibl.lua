local add_on_event = require("pack").add_on_event

add_on_event("UIEnter", {
  {
    src = "lukas-reineke/indent-blankline.nvim",
    module_name = "ibl",
    opts = {
      indent = {
        char = require("icons").misc.vertical_bar,
      },
      scope = {
        show_start = false,
        show_end = false,
      },
    },
  },
})
