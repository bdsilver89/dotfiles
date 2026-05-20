vim.pack.add({
  "https://github.com/folke/flash.nvim",
})

require("flash").setup()

vim.keymap.set({ "n", "x", "o" }, "s", function()
  require("flash").jump()
end, { desc = "Flash" })

vim.keymap.set({ "n", "x", "o" }, "S", function()
  require("flash").treesitter()
end, { desc = "Flash treesitter" })

vim.keymap.set("o", "r", function()
  require("flash").remote()
end, { desc = "Flash treesitter" })
