vim.g.mapleader = " "

vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0

vim.o.autocomplete = true
vim.o.autoread = true
vim.o.breakindent = true
vim.o.colorcolumn = "+1"
vim.o.confirm = true
vim.o.cursorline = true
vim.o.expandtab = true
vim.o.foldexpr = "v:vim.treesitter.foldexpr()"
vim.o.foldlevel = 99
vim.o.foldmethod = "expr"
vim.o.ignorecase = true
vim.o.laststatus = 3
vim.o.list = true
vim.o.number = true
vim.o.pumheight = 10
vim.o.relativenumber = true
vim.o.rulerformat = "%l:%c%V %P"
vim.o.scrolloff = 10
vim.o.shiftwidth = 2
vim.o.signcolumn = "yes"
vim.o.smartcase = true
vim.o.smartindent = true
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.tabstop = 2
vim.o.termguicolors = true
vim.o.timeoutlen = 300
vim.o.undofile = true
vim.o.updatetime = 250
vim.o.wrap = false
vim.opt.completeopt = { "menu", "menuone", "noselect", "popup", "fuzzy" }
vim.opt.fillchars = { eob = " " }
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
vim.opt.shortmess:append("c")

vim.cmd.colorscheme("catppuccin")

vim.schedule(function()
  vim.o.clipboard = "unnamedplus"
end)

vim.o.statusline = table.concat({
  "%<%f %h%w%m%r",
  " %{% v:lua.require('vim._core.util').term_exitcode() %}",
  " %{% exists('b:gitsigns_head') ? ' '..b:gitsigns_head : '' %}",
  " %{% exists('b:gitsigns_status') && b:gitsigns_status != '' ? ' '..b:gitsigns_status : '' %}",
  "%=",
  " %{% &showcmdloc == 'statusline' ? '%-10.S ' : '' %}",
  " %{% exists('b:keymap_name') ? '<'..b:keymap_name..'> ' : '' %}",
  " %{% &busy > 0 ? '◐ ' : '' %}",
  " %{% luaeval('(package.loaded[''vim.diagnostic''] and next(vim.diagnostic.count()) and vim.diagnostic.status() .. '' '') or '''' ') %}",
  " %{% luaeval('vim.iter(vim.lsp.get_clients({bufnr=0})):map(function(c) return c.name end):join(\",\")') %}",
  " %{% &filetype != '' ? &filetype..' ' : '' %}",
  " %{% &fileencoding != '' ? &fileencoding : &encoding %}",
  " %{% &fileformat != 'unix' ? ' '..&fileformat : '' %}",
  " %{% &ruler ? ( &rulerformat == '' ? ' %-14.(%l,%c%V%) %P' : &rulerformat ) : '' %}",
})

require("vim._core.ui2").enable({ msg = { targets = "msg" } })

vim.diagnostic.config({
  severity_sort = true,
  underline = true,
  update_in_insert = false,
  virtual_lines = {
    current_line = true,
  },
  virtual_text = {
    current_line = false,
  },
})
