vim.pack.add({
  "https://github.com/nvim-mini/mini.nvim",
})

require("mini.icons").setup()
MiniIcons.mock_nvim_web_devicons()
MiniIcons.tweak_lsp_kind()

require("mini.pairs").setup()
require("mini.surround").setup()

-- local statusline = require("mini.statusline")
-- statusline.setup()
-- statusline.section_location = function()
--   return "%2l:%-2v"
-- end
