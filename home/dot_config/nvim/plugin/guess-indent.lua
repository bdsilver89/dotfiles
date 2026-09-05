vim.pack.add({
  "https://github.com/NMAC427/guess-indent.nvim",
}, { load = false })

vim.api.nvim_create_autocmd({ "BufReadPre", "BufNewFile" }, {
  once = true,
  callback = function()
    vim.cmd.packadd("guess-indent")
    require("guess-indent").setup()
  end,
})
