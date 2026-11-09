local icons = require("mini.icons")
icons.setup()
icons.mock_nvim_web_devicons()

require("mini.pairs").setup({
  modes = {
    insert = true,
    command = true,
    terminal = false,
  }
})

