vim.pack.add({
  "https://github.com/ibhagwan/fzf-lua",
})

local function pick(name)
  return function()
    require("fzf-lua")[name]()
  end
end

vim.keymap.set("n", "<leader><space>", pick("files"), { desc = "Find files" })
vim.keymap.set("n", "<leader>/", pick("live_grep"), { desc = "Live grep" })
