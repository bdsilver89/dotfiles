-- ============================================================================
-- Utils
-- ============================================================================
local gh = function(repo) return "https://github.com/" .. repo end
local add = vim.pack.add

local group = vim.api.nvim_create_augroup("config", { clear = true })
local new_autocmd = function(event, pattern, callback, desc)
  local opts = { group = group, pattern = pattern, callback = callback, desc = desc }
  vim.api.nvim_create_autocmd(event, opts)
end

local on_packchanged = function(plugin_name, kinds, callback, desc)
  local f = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    if not (name == plugin_name and vim.tbl_contains(kinds, kind)) then return end
    if not ev.data.active then vim.cmd.packadd(plugin_name) end
    callback(ev.data)
  end
  new_autocmd("PackChanged", "*", f, desc)
end

local now = function(f)
  local ok, err = xpcall(f, debug.traceback)
  if not ok then
    vim.schedule(function() vim.notify(tostring(err), vim.log.levels.WARN) end)
  end
  return ok
end

local later = function(f) vim.schedule(function() now(f) end) end
local now_if_args = vim.fn.argc(-1) > 0 and now or later

local map = function(mode, lhs, rhs, opts)
  opts = type(opts) == "string" and { desc = opts } or opts or {}
  vim.keymap.set(mode, lhs, rhs, opts)
end
local nmap = function(lhs, rhs, opts) map("n", lhs, rhs, opts) end
local xmap = function(lhs, rhs, opts) map("x", lhs, rhs, opts) end
local tmap = function(lhs, rhs, opts) map("t", lhs, rhs, opts) end
local map_leader = function(mode, lhs, rhs, opts) map(mode, "<leader>" .. lhs, rhs, opts) end
local nmap_leader = function(lhs, rhs, opts) map_leader("n", lhs, rhs, opts) end
local xmap_leader = function(lhs, rhs, opts) map_leader("x", lhs, rhs, opts) end

-- ============================================================================
-- Options
-- ============================================================================
vim.g.mapleader = " "

vim.o.autocomplete = true
vim.o.breakindent = true
vim.o.completeopt = "menuone,noselect,popup,fuzzy"
vim.o.complete = ".,w,b,o"
vim.o.confirm = true
vim.o.cursorline = true
vim.o.expandtab = true
vim.o.ignorecase = true
vim.o.laststatus = 3
vim.o.listchars = "tab:» ,trail:·,nbsp:␣"
vim.o.list = true
vim.o.number = true
vim.o.pumheight = 10
vim.o.pummaxwidth = 100
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
vim.o.wrap = false

later(function() vim.o.clipboard = "unnamedplus" end)

-- ============================================================================
-- Autocmds
-- ============================================================================
new_autocmd("TextYankPost", "*", function() vim.hl.hl_op() end, "Highlight yank")
new_autocmd("VimResized", "*", function() vim.cmd("tabdo wincmd =") end, "Resize splits")
new_autocmd("FileType", "directory", function() vim.opt_local.bufhidden = true end, "Directory hidden")

-- ============================================================================
-- Keymaps
-- ============================================================================
nmap("j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
nmap("k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

nmap("<c-d>", "<c-d>zz")
nmap("<c-u>", "<c-u>zz")
nmap("n", "nzzzv")
nmap("N", "Nzzzv")

nmap("<esc>", function()
  local ns = vim.api.nvim_create_namespace("nvim.multicursor")
  vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
  vim.cmd.nohlsearch()
end)

nmap_leader("-", "<c-w>s")
nmap_leader("|", "<c-w>v")
nmap_leader("w", "<cmd>w<cr>")
nmap_leader("q", "<cmd>q<cr>")
nmap_leader("bd", "<cmd>bd<cr>")

-- nmap_leader("<space>", "<cmd>Pick files<cr>")
-- nmap_leader("/", "<cmd>Pick grep_live<cr>")
-- nmap_leader(",", "<cmd>Pick buffers<cr>")
--
-- nmap_leader("gc", "<cmd>Git commit<cr>")
-- nmap_leader("gd", "<cmd>Git diff<cr>")
-- nmap_leader("gl", "<cmd>Pick git_commits<cr>")
-- nmap_leader("gb", "<cmd>Pick git_branches<cr>")
-- nmap_leader("gh", "<cmd>Pick git_hunks<cr>")

nmap_leader("xl", function()
  if vim.fn.getloclist(0, { winid = 0 }).winid ~= 0 then
    vim.cmd.lclose()
  else
    vim.cmd.lopen()
  end
end)
nmap_leader("xq", function()
  if vim.fn.getqflist({ winid = 0 }).winid ~= 0 then
    vim.cmd.cclose()
  else
    vim.cmd.copen()
  end
end)

xmap("<", "<gv")
xmap(">", ">gv")

tmap("<esc><esc>", "<c-\\><c-n>")

-- ============================================================================
-- Plugins
-- ============================================================================
vim.cmd.packadd("nvim.difftool")
vim.cmd.packadd("nvim.undotree")

require("vim._core.ui2").enable({
  enable = true,
  msg = {
    targets = {
      progress = "msg",
    },
  },
})

local setup_treesitter = function()
  local ts_update = function() vim.cmd("TSUpdate") end
  on_packchanged("nvim-treesitter", { "update" }, ts_update, ":TSUpdate")

  add({ gh("nvim-treesitter/nvim-treesitter") })

  local languages = {
    "bash",
    "c", "cmake", "cpp",
    "diff",
    "html",
    "java",
    "javascript",
    "json", "json5",
    "lua", "luadoc", "luap",
    "markdown", "markdown_inline",
    "printf",
    "query",
    "regex",
    "python",
    "rust",
    "toml",
    "typescript", "tsx",
    "vim", "vimdoc",
    "xml",
    "yaml",
  }
  local isnt_installed = function(lang)
    return #vim.api.nvim_get_runtime_file("parser/" .. lang .. ".*", false) == 0
  end
  local to_install = vim.tbl_filter(isnt_installed, languages)
  if #to_install > 0 then require("nvim-treesitter").install(to_install) end

  local filetypes = {}
  for _, lang in ipairs(languages) do
    for _, ft in ipairs(vim.treesitter.language.get_filetypes(lang)) do
      table.insert(filetypes, ft)
    end
  end
  local ts_start = function(ev) vim.treesitter.start(ev.buf) end
  new_autocmd("FileType", filetypes, ts_start, "Start tree-sitter")
end
now_if_args(setup_treesitter)

local setup_mini = function()
  add({ gh("nvim-mini/mini.nvim") })

  now(function()
    require("mini.icons").setup()
    later(MiniIcons.mock_nvim_web_devicons)
    later(MiniIcons.tweak_lsp_kind)
  end)

  later(function() require("mini.diff").setup() end)
  later(function() require("mini.git").setup() end)
  later(function() require("mini.bufremove").setup() end)
  later(function() require("mini.statuscolumn").setup() end)
  later(function() require("mini.statusline").setup() end)
  later(function() require("mini.tabline").setup() end)

  later(function()
    local indentscope = require("mini.indentscope")
    indentscope.setup({ draw = { animation = indentscope.gen_animation.none() } })
  end)

  later(function() require("mini.pairs").setup() end)
  later(function() require("mini.surround").setup() end)
  later(function() require("mini.pick").setup() end)
  later(function() require("mini.extra").setup() end)
  later(function() require("mini.jump").setup() end)
  later(function() require("mini.jump").setup() end)
  later(function() require("mini.jump2d").setup() end)
end
now(setup_mini)

-- ============================================================================
-- LSP
-- ============================================================================
local setup_lspconfig = function()
  add({ gh("neovim/nvim-lspconfig") })
end
later(setup_lspconfig)

local servers = {
  "bashls",
  "basedpyright",
  "clangd",
  "jdtls",
  "rust_analyzer",
  "ruff",
}
later(function() vim.lsp.enable(servers) end)

local diagnostic_opts = {
  update_in_insert = false,
  virtual_text = true,
  jump = {
    on_jump = function(_, bufnr)
      vim.diagnostic.open_float({ bufnr = bufnr, scope = "cursor", focus = false })
    end,
  },
}
later(function() vim.diagnostic.config(diagnostic_opts) end)

local on_attach = function(ev)
  local client = vim.lsp.get_client_by_id(ev.data.client_id)
  if not client then return end

  nmap("gd", vim.lsp.buf.definition, { buffer = ev.buf })
  nmap("gD", vim.lsp.buf.declaration, { buffer = ev.buf })
  nmap("gW", vim.lsp.buf.workspace_symbol, { buffer = ev.buf })

  if client:supports_method("textDocument/completion") then
    vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = false })
  end
end
new_autocmd("LspAttach", "*", on_attach, "LSP attach")

local on_progress = function(ev)
  local client = vim.lsp.get_client_by_id(ev.data.client_id)
  local name = client and client.name or ""
  local data = ev.data.params.value
  local msg = name .. ": " .. (data.title or "") .. (data.message and " " .. data.message or "")
  local status = data.kind == "end" and "success" or "running"
  vim.api.nvim_echo({ { msg } }, false, {
    kind = "progress",
    source = name,
    id = "lsp_progress_" .. ev.data.client_id .. "_" .. tostring(ev.data.params.token),
    status = status,
    percent = data.percentage,
  })
end
new_autocmd("LspProgress", "*", on_progress, "LSP progress")
