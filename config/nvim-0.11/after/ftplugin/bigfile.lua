vim.notify("Big file detected, some Neovim features have been **disabled**", vim.log.levels.WARN)

if vim.fn.exists(":NoMatchParen") ~= 0 then
  vim.cmd([[NoMatchParen]])
end

vim.opt_local.foldmethod = "manual"
vim.opt_local.statuscolumn = ""
vim.opt_local.conceallevel = 0

vim.b.minianimate_disable = true
