vim.pack.add({
  "https://github.com/MeanderingProgrammer/render-markdown.nvim",
  "https://github.com/iamcco/markdown-preview.nvim",
})

require("render-markdown").setup()

vim.keymap.set("n", "<leader>um", function()
  local rm = require("render-markdown")
  local enabled = require("render-markdown.state").enabled
  if enabled then
    rm.disable()
  else
    rm.enable()
  end
end, { desc = "Toggle markdown render" })
