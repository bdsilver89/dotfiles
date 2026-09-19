vim.pack.add({
  "https://github.com/nvim-mini/mini.nvim",
})

local icons = require("mini.icons")
icons.setup()
icons.mock_nvim_web_devicons()
icons.tweak_lsp_kind()

require("mini.pairs").setup()
require("mini.surround").setup()

-- local statusline = require("mini.statusline")
-- statusline.setup()
-- statusline.section_location = function()
--   return "%2l:%-2v"
-- end

-- local statuscolumn = require("mini.statuscolumn")
-- statuscolumn.setup({
--   dim_inactive = false,
--   content = statuscolumn.gen_content.main({
--     { format = "sfl", lnum = "%4l", sep = "" },
--   }),
-- })
