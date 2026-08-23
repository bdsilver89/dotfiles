local add_on_event = require("pack").add_on_event

add_on_event({ "BufReadPre", "BufNewFile" }, {
  {
    src = "NMAC427/guess-indent.nvim",
  },
})
