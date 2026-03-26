-- Globals ====================================================================

vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.g.netrw_banner = 0
vim.g.netrw_altv = 1
vim.g.netrw_browse_split = 4
vim.g.netrw_liststyle = 3
vim.g.netrw_winsize = 25
vim.g.netrw_clipboard = 0
vim.g.netrw_fastbrowse = 2
vim.g.netrw_list_hide = vim.fn.join(vim.fn.map(vim.fn.split(vim.o.wildignore, ','), 'v:val .. ".*"'), ',')

-- Options ====================================================================

vim.opt.breakindent = true
vim.opt.clipboard = vim.env.SSH_TTY and "" or "unnamedplus"
vim.opt.confirm = true
vim.opt.cursorline = true
vim.opt.expandtab = true
vim.opt.foldlevel = 99
vim.opt.foldmethod = "indent"
vim.opt.ignorecase = true
vim.opt.laststatus = 3
vim.opt.linebreak = true
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣", }
vim.opt.mouse = "a"
vim.opt.number = true
vim.opt.pumblend = 10
vim.opt.pumheight = 10
vim.opt.relativenumber = true
vim.opt.scrolloff = 4
vim.opt.shiftwidth = 2
vim.opt.sidescrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.smartcase = true
vim.opt.smoothscroll = true
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.tabstop = 2
vim.opt.termguicolors = true
vim.opt.undofile = true
vim.opt.undolevels = 10000
vim.opt.virtualedit = "block"
vim.opt.wildmode = "longest:full,full"
vim.opt.wrap = false

vim.diagnostic.config({
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = " ",
      [vim.diagnostic.severity.WARN] = " ",
      [vim.diagnostic.severity.INFO] = " ",
      [vim.diagnostic.severity.HINT] = " ",
    },
  },
  virtual_text = true,
})

require("vim._core.ui2").enable({
  enable = true,
  msg = {
    target = "msg"
  },
})

-- Plugins ====================================================================

vim.pack.add({
  "https://github.com/tpope/vim-sleuth",
  "https://github.com/christoomey/vim-tmux-navigator",
  "https://github.com/nvim-treesitter/nvim-treesitter",
  "https://github.com/neovim/nvim-lspconfig",
  "https://github.com/saghen/blink.cmp",
  "https://github.com/mason-org/mason.nvim",
  "https://github.com/mason-org/mason-lspconfig.nvim",
  "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim",
  "https://github.com/nvim-lua/plenary.nvim",
  "https://github.com/nvim-tree/nvim-web-devicons",
  "https://github.com/nvim-telescope/telescope.nvim",
  "https://github.com/nvim-lualine/lualine.nvim",
  "https://github.com/folke/which-key.nvim",
})

-- Treesitter
local languages = {
  "bash",
  "c",
  "cmake",
  "cpp",
  "diff",
  "dockerfile",
  "java",
  "javascript",
  "json",
  "make",
  "markdown",
  "markdown_inline",
  "printf",
  "python",
  "query",
  "regex",
  "rust",
  "toml",
  "html",
  "vim",
  "vimdoc",
  "xml",
  "yaml",
}
local filetypes = {}
for _, lang in ipairs(languages) do
  for _, ft in ipairs(vim.treesitter.language.get_filetypes(lang)) do
    table.insert(filetypes, ft)
  end
end
local to_install = vim.tbl_filter(function(l)
  return #vim.api.nvim_get_runtime_file("parser/" .. l .. ".*", false) == 0
end, languages)
if #to_install > 0 then
  require("nvim-treesitter").install(to_install)
end

-- Blink.cmp
require("blink.cmp").setup({
  completion = {
    documentation = {
      auto_show = true,
    },
    ghost_text = {
      enabled = true,
    },
  },
  fuzzy = { implementation = "lua" },
  keymap = {
    preset = "enter",
    ["<C-y>"] = { "select_and_accept" },
  },
  sources = {
    default = { "lsp", "path", "snippets", "buffer" },
  },
})

-- Mason + LSP
require("mason").setup()
require("mason-lspconfig").setup()
require("mason-tool-installer").setup({
  ensure_installed = {
    "lua_ls",
    "stylua",
  },
})

-- Telescope
require("telescope").setup({})

-- Lualine
require("lualine").setup({
  options = {
    section_separators = { left = "", right = "" },
    component_separators = { left = "", right = "" },
  },
})

-- Which-Key
require("which-key").setup({
  spec = {
    { "<leader>q", group = "Session/Quit" },
  },
})

-- Keymaps ====================================================================

vim.keymap.set("n", "<esc>", "<cmd>nohlsearch<cr>")

vim.keymap.set("x", "<", "<gv")
vim.keymap.set("x", ">", ">gv")

vim.keymap.set("i", ",", ",<c-g>u")
vim.keymap.set("i", ".", ".<c-g>u")
vim.keymap.set("i", ";", ";<c-g>u")

vim.keymap.set("n", "<leader>w", "<cmd>w<cr>")
vim.keymap.set("n", "<leader>q", "<cmd>q<cr>")
vim.keymap.set("n", "<leader>qq", "<cmd>qa<cr>")

-- stylua: ignore start
local pickers = require("telescope.builtin")
vim.keymap.set("n", "<leader><space>", pickers.find_files, { desc = "Find Files" })
vim.keymap.set("n", "<leader>/", pickers.live_grep, { desc = "Grep" })
vim.keymap.set("n", "<leader>,", pickers.buffers, { desc = "Buffers" })
-- stylua: ignore end

-- Autocmds ===================================================================

local group = vim.api.nvim_create_augroup("config", { clear = true })

vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight on text yank",
  group = group,
  callback = function()
    vim.hl.on_yank()
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  desc = "Start treesitter",
  pattern = filetypes,
  group = group,
  callback = function(ev)
    vim.treesitter.start(ev.buf)
    vim.wo.foldmethod = "expr"
    vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end,
})

vim.api.nvim_create_autocmd("LspAttach", {
  desc = "LSP setup",
  group = group,
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if not client then
      return
    end

    -- stylua: ignore start
    vim.keymap.set("n", "grd", vim.lsp.buf.definition, { desc = "vim.lsp.buf.definition()", buffer = ev.buf })
    vim.keymap.set("n", "grD", vim.lsp.buf.declaration, { desc = "vim.lsp.buf.declaration()", buffer = ev.buf })
    vim.keymap.set("n", "grf", vim.lsp.buf.format, { desc = "vim.lsp.buf.format()", buffer = ev.buf })
    -- stylua: ignore end
  end,
})

