local notify = require('notify')

notify.setup({
  stages = 'slide',
  on_open = nil,
  on_close = nil,
  timeout = 5000,
  render = 'default',
  background_colour = 'Normal',
  minimum_width = 50,
  level = "TRACE",
  icons = {
	  ERROR = "",
    WARN = "",
    INFO = "",
    DEBUG = "",
    TRACE = "✎",
  },
})

vim.notify = notify
