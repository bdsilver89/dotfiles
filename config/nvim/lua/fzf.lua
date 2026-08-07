vim.pack.add({
  "https://github.com/ibhagwan/fzf-lua",
})

local fzf = require("fzf-lua")
fzf.setup()

vim.keymap.set("n", "<leader><space>", fzf.files, { desc = "Find files" })
vim.keymap.set("n", "<leader>/", fzf.live_grep, { desc = "Live grep" })
