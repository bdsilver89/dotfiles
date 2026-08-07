vim.pack.add({
  "https://github.com/nvim-mini/mini.nvim",
})

require("mini.bufremove").setup()
vim.keymap.set("n", "<leader>bd", function()
  MiniBufremove.delete(0, false)
end, { desc = "Close buffer" })

require("mini.icons").setup()
MiniIcons.mock_nvim_web_devicons()

require("mini.pairs").setup({
  -- skip_next = [=[[%w%%%'%[%"%.%`%$]]=],
  -- skip_ts = { "string" },
  -- skip_unbalanced = true,
  -- markdown = true,
})

require("mini.surround").setup()

local statusline = require("mini.statusline")
statusline.setup()

---@diagnostic disable-next-line: duplicate-set-field
statusline.section_location = function()
  return "%2l:%-2v  %P"
end
