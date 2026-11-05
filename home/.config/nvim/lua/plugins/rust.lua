vim.api.nvim_create_autocmd("BufRead", {
  pattern = "Cargo.toml",
  once = true,
  callback = function()
    vim.cmd.packadd("crates.nvim")
    require("crates").setup({})
  end,
})
