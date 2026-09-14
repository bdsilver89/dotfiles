-- ============================================================================
-- Options
-- ============================================================================
vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.o.autocomplete = true
vim.o.autocompletedelay = 200
vim.o.clipboard = "unnamedplus"
vim.o.cmdheight = 0
vim.o.complete = ".,w,b,o"
vim.o.completeopt = "menu,menuone,noselect,preview,fuzzy"
vim.o.confirm = true
vim.o.cursorline = true
vim.o.expandtab = true
vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.o.foldlevel = 99
vim.o.foldmethod = "expr"
vim.o.ignorecase = true
vim.o.laststatus = 3
vim.o.list = true
vim.o.listchars = "tab:» ,trail:·,nbsp:␣"
vim.o.number = true
vim.o.pumheight = 10
vim.o.relativenumber = true
vim.o.scrolloff = 8
vim.o.sidescrolloff = 8
vim.o.signcolumn = "yes"
vim.o.smartcase = true
vim.o.smartindent = true
vim.o.softtabstop = 2
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.tabstop = 2
vim.o.undofile = true
vim.o.virtualedit = "block"
vim.o.wrap = false

require("vim._core.ui2").enable({ msg = { targets = "msg" } })

-- ============================================================================
-- Keymaps
-- ============================================================================
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
vim.keymap.set("n", "<down>", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set("n", "<up>", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

vim.keymap.set("n", "<c-d>", "<c-d>zz")
vim.keymap.set("n", "<c-u>", "<c-u>zz")
vim.keymap.set("n", "N", "Nzzzv")
vim.keymap.set("n", "n", "nzzzv")

vim.keymap.set("n", "<leader>-", "<c-w>s")
vim.keymap.set("n", "<leader>|", "<c-w>v")
vim.keymap.set("n", "<leader>q", "<cmd>q<cr>")
vim.keymap.set("n", "<leader>w", "<cmd>w<cr>")
vim.keymap.set("n", "<leader>bd", "<cmd>bd<cr>")
vim.keymap.set("n", "<leader>xq", function()
  local success, err = pcall(vim.fn.getqflist({ winid = 0 }).winid ~= 0 and vim.cmd.cclose or vim.cmd.copen)
  if not success and err then
    vim.notify(err, vim.log.levels.ERROR)
  end
end)
vim.keymap.set("n", "<leader>xl", function()
  local success, err = pcall(vim.fn.getloclist(0, { winid = 0 }).winid ~= 0 and vim.cmd.lclose or vim.cmd.lopen)
  if not success and err then
    vim.notify(err, vim.log.levels.ERROR)
  end
end)

vim.keymap.set("x", "<", "<gv")
vim.keymap.set("x", ">", ">gv")

vim.keymap.set("t", "<esc><esc>", "<c-\\><c-n>")

vim.keymap.set("n", "<esc>", function()
  local ns = vim.api.nvim_create_namespace("nvim.multicursor")
  if #vim.api.nvim_buf_get_extmarks(0, ns, 0, -1, { limit = 1 }) > 0 then
    vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
  else
    vim.cmd("noh")
  end
end)

-- ============================================================================
-- Autocmds
-- ============================================================================
local group = vim.api.nvim_create_augroup("config", { clear = true })

vim.api.nvim_create_autocmd("TextYankPost", {
  group = group,
  callback = function() vim.hl.hl_op() end,
})

vim.api.nvim_create_autocmd("VimResized", {
  group = group,
  command = "wincmd =",
})

vim.api.nvim_create_autocmd("Filetype", {
  group = group,
  pattern = "directory",
  callback = function() vim.opt_local.bufhidden = "wipe" end,
})

-- ============================================================================
-- Plugins
-- ============================================================================
vim.pack.add({
  { src = "https://github.com/catppuccin/nvim", name = "catppuccin" },
  "https://github.com/nvim-treesitter/nvim-treesitter",
  "https://github.com/neovim/nvim-lspconfig",
  "https://github.com/ibhagwan/fzf-lua",
  "https://github.com/lewis6991/gitsigns.nvim",
  "https://github.com/tpope/vim-fugitive",
  "https://github.com/tpope/vim-dispatch",
  "https://github.com/tpope/vim-sleuth",
  "https://github.com/christoomey/vim-tmux-navigator",
  "https://github.com/vim-test/vim-test",
})

vim.cmd.colorscheme("catppuccin")

require("nvim-treesitter").install({
  "bash",
  "c", "cmake", "cpp",
  "java",
  "javascript",
  "json",
  "lua",
  "markdown", "markdown_inline",
  "python",
  "query", "regex",
  "rust",
  "typescript",
  "vim", "vimdoc",
  "xml",
  "yaml",
})
vim.api.nvim_create_autocmd("FileType", {
  group = group,
  callback = function(ev) pcall(vim.treesitter.start, ev.buf) end,
})
vim.api.nvim_create_autocmd("PackChanged", {
  pattern = "nvim-treesitter",
  command = "TSUpdate"
})

require("fzf-lua").setup({
  keymap = {
    fzf = { ["ctrl-q"] = "select-all+accept" },
  },
})
require("fzf-lua").register_ui_select()

vim.keymap.set("n", "<leader>sf", "<cmd>FzfLua files<cr>")
vim.keymap.set("n", "<leader>sg", "<cmd>FzfLua live_grep<cr>")
vim.keymap.set("n", "<leader>sb", "<cmd>FzfLua buffers<cr>")

vim.keymap.set("n", "<leader>gb", "<cmd>FzfLua git_branches<cr>")
vim.keymap.set("n", "<leader>gl", "<cmd>FzfLua git_commits<cr>")
vim.keymap.set("n", "<leader>gs", "<cmd>FzfLua git_status<cr>")


-- ============================================================================
-- LSP
-- ============================================================================
vim.diagnostic.config({
  severity_sort = true,
  virtual_lines = { current_line = true },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = " ",
      [vim.diagnostic.severity.WARN] = " ",
      [vim.diagnostic.severity.HINT] = " ",
      [vim.diagnostic.severity.INFO] = " ",
    },
  },
})

vim.lsp.enable({ "basedpyright", "clangd", "jdtls", "rust_analyzer" })

vim.api.nvim_create_autocmd("LspProgress", {
  group = group,
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    local value = ev.data.params.value
    local token = ev.data.params.token or "default"
    local icon = value.kind == "end" and "" or ""
    local text = value.message or (value.kind == "end" and "Done" or "Loading...")
    local client_name = client and client.name or "LSP"
    local display_str = string.format("[%s] %s %s: %s", client_name, icon, value.title or "", text)
    vim.api.nvim_echo({ { display_str } }, false, {
      id = "lsp_progress_" .. ev.data.client_id .. "_" .. tostring(token),
      kind = "progress",
      source = "vim.lsp",
      title = value.title,
      status = value.kind ~= "end" and "running" or "success",
      percent = value.percent,
    })
  end,
})

vim.api.nvim_create_autocmd("LspAttach", {
  group = group,
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)

    vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "vim.lsp.buf.definition()", buffer = ev.buf })
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { desc = "vim.lsp.buf.declaration()", buffer = ev.buf })
    vim.keymap.set("n", "gW", vim.lsp.buf.workspace_symbol, { desc = "vim.lsp.buf.workspace_symbol()", buffer = ev.buf })

    if client and client:supports_method("textDocument/completion") then
      vim.lsp.completion.enable(true, client.id, ev.buf)
    end
  end,
})
