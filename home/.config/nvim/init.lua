-- ============================================================================
-- Options
-- ============================================================================
vim.loader.enable()

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- vim.o.autocomplete = true
vim.o.breakindent = true
vim.o.completeopt = "menuone,noselect,popup,fuzzy"
-- vim.o.complete = ".,w,b,o"
vim.o.confirm = true
vim.o.cursorline = true
vim.o.expandtab = true
vim.o.ignorecase = true
vim.o.laststatus = 3
vim.o.listchars = "tab:» ,trail:·,nbsp:␣"
vim.o.list = true
vim.o.number = true
vim.o.pumheight = 10
vim.o.relativenumber = true
vim.o.scrolloff = 5
vim.o.shiftwidth = 4
vim.o.signcolumn = "yes"
vim.o.smartcase = true
vim.o.softtabstop = 4
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.undofile = true
vim.o.updatetime = 250
vim.o.virtualedit = "block"

vim.schedule(function() vim.o.clipboard = "unnamedplus" end)

require("vim._core.ui2").enable({})

-- ============================================================================
-- Plugins
-- ============================================================================
vim.pack.add({
  "https://github.com/nvim-treesitter/nvim-treesitter",
  "https://github.com/nvim-mini/mini.nvim",
})

-- treesitter
do
  local parsers = {
    "bash",
    "c",
    "cmake",
    "cpp",
    "diff",
    "html",
    "java",
    "javascript",
    "json",
    "lua",
    "markdown",
    "markdown_inline",
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

  local ts = require("nvim-treesitter")
  local installed = require("nvim-treesitter.config").get_installed()
  ts.install(vim.iter(parsers)
    :filter(function(p)
      return not vim.tbl_contains(installed, p)
    end)
    :totable())
end

-- mini
do
  require("mini.indentscope").setup({ draw = { animation = require("mini.indentscope").gen_animation.none() } })
  require("mini.pairs").setup()
  require("mini.diff").setup({ view = { style = "sign" } })
  require("mini.git").setup()
  require("mini.pick").setup()
  require("mini.extra").setup()
end

-- ============================================================================
-- Keymaps
-- ============================================================================
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

vim.keymap.set("n", "<esc>", "<cmd>nohlsearch<cr>")

vim.keymap.set("n", "<leader>-", "<c-w>s")
vim.keymap.set("n", "<leader>|", "<c-w>v")
vim.keymap.set("n", "<leader>w", "<cmd>write<cr>")
vim.keymap.set("n", "<leader>q", "<cmd>quit<cr>")
vim.keymap.set("n", "<leader>bd", "<cmd>bd<cr>")

vim.keymap.set("n", "<leader><space>", "<cmd>Pick files<cr>")
vim.keymap.set("n", "<leader>/", "<cmd>Pick grep_live<cr>")
vim.keymap.set("n", "<leader>,", "<cmd>Pick buffers<cr>")
vim.keymap.set("n", "<leader>:", "<cmd>Pick history<cr>")

vim.keymap.set("n", "<leader>gb", "<cmd>Pick git_branches<cr>")
vim.keymap.set("n", "<leader>gc", "<cmd>Pick git_commits<cr>")

vim.keymap.set("n", "<leader>xl", function()
  if vim.fn.getloclist(0, { winid = 0 }).winid ~= 0 then
    vim.cmd.lclose()
  else
    vim.cmd.lopen()
  end
end)

vim.keymap.set("n", "<leader>xq", function()
  if vim.fn.getqflist({ winid = 0 }).winid ~= 0 then
    vim.cmd.cclose()
  else
    vim.cmd.copen()
  end
end)

vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")

vim.keymap.set("t", "<esc><esc>", "<c-\\><c-n>")

-- ============================================================================
-- Autocmds
-- ============================================================================
local group = vim.api.nvim_create_augroup("config", { clear = true })

vim.api.nvim_create_autocmd("TextYankPost", {
  group = group,
  callback = function()
    vim.hl.hl_op()
  end,
})

vim.api.nvim_create_autocmd("VimResized", {
  group = group,
  command = "wincmd =",
})

vim.api.nvim_create_autocmd("FileType", {
  group = group,
  callback = function(ev)
    pcall(vim.treesitter.start, ev.buf)
    vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end,
})

vim.api.nvim_create_autocmd("PackChanged", {
  group = group,
  callback = function(ev)
    local name = ev.data.spec.name
    local kind = ev.data.kind
    if kind ~= "install" and kind ~= "update" then return end

    if name == "nvim-treesitter" then
      if not ev.data.active then vim.cmd.packadd("nvim-treesitter") end
      vim.cmd("TSUpdate")
    end
  end,
})

-- ============================================================================
-- LSP
-- ============================================================================
local servers = {
  "clangd",
  "rust_analyzer",
}
vim.lsp.enable(servers)

vim.diagnostic.config({
  update_in_insert = false,
  severity_sort = true,
  float = { source = "if_many" },
  underline = { severity = { min = vim.diagnostic.severity.WARN } },
  virtual_text = true,
  jump = {
    on_jump = function(_, bufnr)
      vim.diagnostic.open_float({
        bufnr = bufnr,
        scope = "cursor",
        focus = false,
      })
    end,
  },
})

vim.api.nvim_create_autocmd("LspAttach", {
  group = group,
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if not client then
      return
    end

    local function map(lhs, rhs)
      vim.keymap.set("n", lhs, rhs, { buffer = ev.buf })
    end

    map("gd", vim.lsp.buf.definition)
    map("gD", vim.lsp.buf.declaration)
    map("gW", vim.lsp.buf.workspace_symbol)

    if client:supports_method("textDocument/completion") then
      vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = false })
    end
    if client:supports_method("textDocument/inlineCompletion") then
      vim.lsp.inline_completion.enable(true, { bufnr = ev.buf })
    end
  end,
})

-- vim.api.nvim_create_autocmd("LspProgress", {
--   group = group,
--   callback = function(ev)
--     local data = ev.data.params.value
--     local client = vim.lsp.get_client_by_id(ev.data.client_id)
--     local name = client and client.name or ""
--     local msg = name .. ": " .. (data.title or "") .. (data.message and " " .. data.message or "")
--     local status = data.kind == "end" and "success" or "running"
--     vim.api.nvim_echo({ { msg } }, false, {
--       kind = "progress",
--       source = name,
--       id = "lsp_progress_" .. ev.data.client_id,
--       status = status,
--       percent = data.percentage,
--     })
--   end,
-- })
