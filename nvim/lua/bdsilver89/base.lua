vim.cmd("autocmd!")

vim.scriptendcoding = 'utf-8'
vim.opt.encoding = 'utf-8'
vim.opt.fileencoding = 'utf-8'

vim.wo.number = true

vim.opt.title = true
vim.opt.hlsearch = true
vim.opt.showcmd = true
vim.opt.backup = false
vim.opt.cmdheight = 1
vim.opt.laststatus = 2
vim.opt.expandtab = true
vim.opt.scrolloff = 10
vim.opt.shell = 'zsh'
vim.opt.backupskip = { '/tmp/*', '/private/tmp' }
vim.opt.ignorecase = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.wrap = false
vim.opt.backspace = { 'start', 'eol', 'indent' }
vim.opt.path:append { '**' }
vim.opt.hidden = true
vim.opt.writebackup = false
vim.opt.updatetime = 300

vim.api.nvim_create_autocmd("InsertLeave", {
	pattern = "*",
	command = "set nopaste"
})

vim.opt.formatoptions:append{ 'r' }
