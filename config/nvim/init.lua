-- Globals ====================================================================

vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 0

-- Options ====================================================================

vim.opt.breakindent = true
vim.schedule(function()
  vim.opt.clipboard = vim.env.SSH_TTY and "" or "unnamedplus"
end)
vim.opt.confirm = true
vim.opt.completeopt = { "menuone", "noselect", "popup", "fuzzy" }
vim.opt.cursorline = true
vim.opt.diffopt:append("linematch:60")
vim.opt.expandtab = true
vim.opt.foldlevel = 99
vim.opt.foldmethod = "indent"
vim.opt.ignorecase = true
vim.opt.laststatus = 3
vim.opt.linebreak = true
vim.opt.shortmess:append("c")
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
vim.opt.mouse = "a"
vim.opt.number = true
vim.opt.pumblend = 10
vim.opt.pumheight = 10
vim.opt.relativenumber = true
vim.opt.ruler = false
vim.opt.scrolloff = 4
vim.opt.shiftwidth = 2
vim.opt.showmode = false
vim.opt.sidescrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.smartcase = true
vim.opt.smoothscroll = true
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.tabstop = 2
vim.opt.termguicolors = true
vim.opt.timeoutlen = 300
vim.opt.undofile = true
vim.opt.undolevels = 10000
vim.opt.updatetime = 250
vim.opt.virtualedit = "block"
vim.opt.wildmode = "longest:full,full"
vim.opt.wrap = false

require("vim._core.ui2").enable({
  enable = true,
  msg = {
    target = "cmd",
  },
})

-- Plugins ====================================================================
vim.cmd.packadd("nvim.difftool")
vim.cmd.packadd("nvim.undotree")

vim.pack.add({
  "https://github.com/tpope/vim-sleuth",
  "https://github.com/nvim-treesitter/nvim-treesitter",
  "https://github.com/mason-org/mason.nvim",
  "https://github.com/ibhagwan/fzf-lua",
  "https://github.com/lewis6991/gitsigns.nvim",
})

vim.cmd.colorscheme("catppuccin")

-- Treesitter
local languages = {
  "bash",
  "c",
  "cmake",
  "cpp",
  "diff",
  "dockerfile",
  "html",
  "html",
  "java",
  "javascript",
  "json",
  "lua",
  "luadoc",
  "luap",
  "make",
  "markdown_inline",
  "markdown",
  "printf",
  "python",
  "query",
  "regex",
  "rust",
  "toml",
  "tsx",
  "typescript",
  "vim",
  "vimdoc",
  "xml",
  "yaml",
}
local filetypes = {}
for _, lang in ipairs(languages) do
  for _, ft in ipairs(vim.treesitter.language.get_filetypes(lang)) do
    filetypes[#filetypes + 1] = ft
  end
end
require("nvim-treesitter").install(languages)

-- Mason (tool installer only — not needed for LSP startup)
require("mason").setup()

-- Fzf-lua
require("fzf-lua").setup({
  "default-title",
  keymap = {
    fzf = {
      ["ctrl-q"] = "select-all+accept",
      ["ctrl-u"] = "half-page-up",
      ["ctrl-d"] = "half-page-down",
      ["ctrl-x"] = "jump",
      ["ctrl-f"] = "preview-page-down",
      ["ctrl-b"] = "preview-page-up",
    },
    builtin = {
      ["<c-f>"] = "preview-page-down",
      ["<c-b>"] = "preview-page-up",
    },
  },
})

-- Git
require("gitsigns").setup({
  current_line_blame = true,
  on_attach = function(buf)
    local gs = require("gitsigns")
    local function map(mode, l, r, desc)
      vim.keymap.set(mode, l, r, { buffer = buf, desc = desc })
    end

    -- stylua: ignore start
    map("n", "]h", function() gs.nav_hunk("next") end, "Next Hunk")
    map("n", "[h", function() gs.nav_hunk("prev") end, "Prev Hunk")
    map("n", "<leader>hs", gs.stage_hunk, "Stage Hunk")
    map("n", "<leader>hr", gs.reset_hunk, "Reset Hunk")
    map("x", "<leader>hs", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Stage Hunk")
    map("x", "<leader>hr", function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Reset Hunk")
    map("n", "<leader>hS", gs.stage_buffer, "Stage Buffer")
    map("n", "<leader>hu", gs.undo_stage_hunk, "Undo Stage Hunk")
    map("n", "<leader>hR", gs.reset_buffer, "Reset Buffer")
    map("n", "<leader>hp", gs.preview_hunk, "Preview Hunk")
    map("n", "<leader>hi", gs.preview_hunk_inline, "Preview Hunk Inline")
    map("n", "<leader>hb", function() gs.blame_line({ full = true }) end, "Blame Line")
    map("n", "<leader>hd", gs.diffthis, "Diff This")
    map("n", "<leader>hD", function() gs.diffthis("~") end, "Diff This ~")
    map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "Inside Hunk")
    -- stylua: ignore end
  end,
})

-- Keymaps ====================================================================

vim.keymap.set({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
vim.keymap.set({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
vim.keymap.set({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })
vim.keymap.set({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })

vim.keymap.set("x", "<", "<gv")
vim.keymap.set("x", ">", ">gv")

vim.keymap.set("i", ",", ",<c-g>u")
vim.keymap.set("i", ".", ".<c-g>u")
vim.keymap.set("i", ";", ";<c-g>u")

vim.keymap.set("n", "<leader>bd", "<cmd>bd<cr>")
vim.keymap.set("n", "<leader>w", "<cmd>w<cr>")
vim.keymap.set("n", "<leader>q", "<cmd>q<cr>")
vim.keymap.set("n", "<leader>qq", "<cmd>qa<cr>")
vim.keymap.set("n", "<leader>-", "<c-w>s")
vim.keymap.set("n", "<leader>|", "<c-w>v")

vim.keymap.set("n", "<esc>", "<cmd>nohlsearch<cr>")
vim.keymap.set("t", "<esc><esc>", "<c-\\><c-n>")

vim.keymap.set("n", "<leader>xl", function()
  local success, err = pcall(vim.fn.getloclist(0, { winid = 0 }).winid ~= 0 and vim.cmd.lclose or vim.cmd.lopen)
  if not success and err then
    vim.notify(err, vim.log.levels.ERROR)
  end
end, { desc = "Location List" })
vim.keymap.set("n", "<leader>xq", function()
  local success, err = pcall(vim.fn.getqflist({ winid = 0 }).winid ~= 0 and vim.cmd.cclose or vim.cmd.copen)
  if not success and err then
    vim.notify(err, vim.log.levels.ERROR)
  end
end, { desc = "Quickfix List" })

vim.keymap.set("n", "-", "<cmd>Ex %:h<cr>", { desc = "File Explorer" })

-- stylua: ignore start
local fzf = require("fzf-lua")
vim.keymap.set("n", "<leader><space>", fzf.files, { desc = "Find Files" })
vim.keymap.set("n", "<leader>/", fzf.live_grep, { desc = "Grep" })
vim.keymap.set("n", "<leader>,", fzf.buffers, { desc = "Buffers" })
vim.keymap.set("n", "<leader>:", fzf.command_history, { desc = "Command History" })
vim.keymap.set("n", "<leader>\"", fzf.registers, { desc = "Registers" })
vim.keymap.set("n", "<leader>s", fzf.resume, { desc = "Resume Last Picker" })
vim.keymap.set("n", "<leader>?", fzf.helptags, { desc = "Help Tags" })
vim.keymap.set("n", "<leader>xd", fzf.diagnostics_workspace, { desc = "Diagnostics" })
vim.keymap.set("n", "<leader>gc", fzf.git_commits, { desc = "Commits" })
vim.keymap.set("n", "<leader>gC", fzf.git_bcommits, { desc = "Buffer Commits" })
vim.keymap.set("n", "<leader>gb", fzf.git_branches, { desc = "Branches" })
vim.keymap.set("n", "<leader>gs", fzf.git_status, { desc = "Status" })
vim.keymap.set("n", "<leader>gS", fzf.git_stash, { desc = "Stash" })
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

vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  desc = "Check for file reload",
  group = group,
  callback = function()
    if vim.o.buftype ~= "nofile" then
      vim.cmd("checktime")
    end
  end,
})

vim.api.nvim_create_autocmd("VimResized", {
  desc = "Resize splits",
  group = group,
  callback = function()
    local current_tab = vim.fn.tabpagenr()
    vim.cmd("tabdo wincmd =")
    vim.cmd("tabnext " .. current_tab)
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  desc = "Netrw keymaps",
  pattern = "netrw",
  group = group,
  callback = function(ev)
    local opts = { buffer = ev.buf, remap = true }
    vim.keymap.set("n", "q", "<cmd>bd<cr>", opts)
    vim.keymap.set("n", ".", function()
      local dir = vim.b[ev.buf].netrw_curdir or ""
      local file = vim.fn.expand("<cfile>")
      return ":" .. vim.fn.fnameescape(dir .. "/" .. file) .. " "
    end, vim.tbl_extend("force", opts, { expr = true }))
    vim.keymap.set("n", "y.", function()
      local dir = vim.b[ev.buf].netrw_curdir or ""
      local file = vim.fn.expand("<cfile>")
      local path = vim.fn.fnamemodify(dir .. "/" .. file, ":p")
      vim.fn.setreg("+", path)
      vim.notify(path)
    end, opts)
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
