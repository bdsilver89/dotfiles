-- ============================================================================
-- Options
-- ============================================================================
vim.loader.enable()

vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_matchit = 1
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0

vim.o.breakindent = true
vim.o.cmdheight = 0
vim.o.completeopt = "menu,menuone,noselect,noinsert,popup,fuzzy"
vim.o.confirm = true
vim.o.cursorline = true
vim.o.expandtab = true
vim.o.fillchars = "eob: "
vim.o.foldlevel = 99
vim.o.foldmethod = "indent"
vim.o.formatoptions = "jrcoqlnt"
vim.o.ignorecase = true
vim.o.inccommand = "split"
vim.o.laststatus = 3
vim.o.list = true
vim.o.listchars = "tab:» ,trail:·,nbsp:␣"
vim.o.mouse = "a"
vim.o.number = true
vim.o.pumheight = 10
vim.o.relativenumber = true
vim.o.scrolloff = 8
vim.o.signcolumn = "yes"
vim.o.smartcase = true
vim.o.smartindent = true
vim.o.softtabstop = 2
vim.o.splitbelow = true
vim.o.splitkeep = "screen"
vim.o.splitright = true
vim.o.tabstop = 2
vim.o.termguicolors = true
vim.o.timeoutlen = 300
vim.o.undofile = true
vim.o.updatetime = 250
vim.o.wrap = false

vim.schedule(function()
  if vim.fn.has("wsl") == 1 then
    vim.g.clipboard = {
      name = "win32yank",
      copy = {
        ["+"] = { "win32yank.exe", "-i", "--crlf" },
        ["*"] = { "win32yank.exe", "-i", "--crlf" },
      },
      paste = {
        ["+"] = { "win32yank.exe", "-o", "--lf" },
        ["*"] = { "win32yank.exe", "-o", "--lf" },
      },
    }
  end

  vim.o.clipboard = "unnamedplus"

  require("vim._core.ui2").enable()
end)

-- ============================================================================
-- Keymaps
-- ============================================================================
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
vim.keymap.set("n", "<down>", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set("n", "<up>", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

vim.keymap.set("n", "<c-d>", "<c-d>zz")
vim.keymap.set("n", "<c-u>", "<c-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

vim.keymap.set("n", "<esc>", "<cmd>noh<cr>")

vim.keymap.set("x", "<", "<gv")
vim.keymap.set("x", ">", ">gv")

vim.keymap.set("t", "<esc>", "<c-\\><c-n>")

-- ============================================================================
-- Autocmds
-- ============================================================================
vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("config_highlightyank", { clear = true }),
  callback = function()
    vim.hl.hl_op()
  end,
})

vim.api.nvim_create_autocmd("VimResized", {
  group = vim.api.nvim_create_augroup("config_resizesplits", { clear = true }),
  callback = function()
    local current_tab = vim.fn.tabpagenr()
    vim.cmd("tabdo wincmd =")
    vim.cmd("tabnext " .. current_tab)
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("config_wrapspell", { clear = true }),
  pattern = { "text", "markdown", "gitcommit" },
  callback = function()
    vim.opt_local.spell = true
    vim.opt_local.wrap = true
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("config_qclose", { clear = true }),
  pattern = {
    "checkhealth",
    "directory",
    "git",
    "gitsigns-blame",
    "help",
    "man",
    "qf",
  },
  callback = function(ev)
    vim.bo[ev.buf].buflisted = false
    vim.schedule(function()
      vim.keymap.set("n", "q", function()
        pcall(vim.api.nvim_buf_delete, ev.buf, { force = true })
      end, { desc = "Quit buffer", silent = true, buffer = ev.buf })
    end)
  end,
})

-- ============================================================================
-- LSP
-- ============================================================================
vim.schedule(function()
  local ok, blink = pcall(require, "blink.cmp")
  if ok then
    vim.lsp.config("*", {
      capabilities = blink.get_lsp_capabilities(nil, true),
    })
  end

  vim.diagnostic.config({
    update_in_insert = false,
    severity_sort = true,
    virtual_text = true,
    virtual_lines = false,
  })

  local servers = vim.iter(vim.api.nvim_get_runtime_file("lsp/*.lua", true))
    :map(function(file) return vim.fn.fnamemodify(file, ":t:r") end)
    :totable()
  vim.lsp.enable(servers)
end)

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if not client then
      return
    end
  end
})
