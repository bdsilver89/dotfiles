-- Options ====================================================================
vim.g.autoformat = true
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0

vim.o.autocomplete = true
vim.o.clipboard = vim.env.SSH_TTY and "" or "unnamedplus"
vim.o.confirm = true
vim.o.cursorline = true
vim.o.expandtab = true
vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.o.foldlevel = 99
vim.o.foldmethod = "expr"
vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
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
vim.opt.fillchars:append({ eob = " " })
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
vim.opt.shortmess:append("c")

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

vim.cmd.colorscheme("catppuccin")

vim.diagnostic.config({
  severity_sort = true,
  underline = true,
  update_in_insert = false,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "",
      [vim.diagnostic.severity.WARN] = "",
      [vim.diagnostic.severity.HINT] = "",
      [vim.diagnostic.severity.INFO] = "",
    },
  },
  virtual_text = true,
})

-- Plugins ====================================================================
vim.pack.add({
  "https://github.com/tpope/vim-sleuth",
  "https://github.com/b0o/SchemaStore.nvim",
  "https://github.com/mason-org/mason.nvim",
  "https://github.com/nvim-treesitter/nvim-treesitter",
  "https://github.com/nvim-treesitter/nvim-treesitter-textobjects",
  "https://github.com/stevearc/oil.nvim",
  "https://github.com/ibhagwan/fzf-lua",
  "https://github.com/folke/which-key.nvim",
  "https://github.com/stevearc/conform.nvim",
  "https://github.com/lewis6991/gitsigns.nvim",
  "https://github.com/mfussenegger/nvim-dap",
  "https://github.com/igorlfs/nvim-dap-view",
  "https://github.com/tpope/vim-dadbod",
  "https://github.com/kristijanhusak/vim-dadbod-completion",
})

require("mason").setup()
local mason_registry = require("mason-registry")
for _, pkg in ipairs({
  -- language servers
  "basedpyright",
  "bash-language-server",
  "copilot-language-server",
  "jdtls",
  "json-lsp",
  "lua-language-server",
  "neocmakelsp",
  "yaml-language-server",

  -- formatters
  "shfmt",
  "stylua",

  -- linters

  -- debuggers
  "codelldb",
  "debugpy",
  "java-debug-adapter",
}) do
  if not mason_registry.is_installed(pkg) then
    mason_registry.get_package(pkg):install()
  end
end

require("nvim-treesitter-textobjects").setup({
  select = { lookahead = true },
  move = {
    enable = true,
    set_jumps = true,
  },
})

require("oil").setup({ keymaps = { ["<C-h>"] = false } })

require("fzf-lua").setup({ keymap = { fzf = { ["ctrl-q"] = "select-all+accept" } } })

require("which-key").setup()
require("which-key").add({
  { "<leader>b", group = "buffer" },
  { "<leader>d", group = "debug" },
  { "<leader>g", group = "git" },
  { "<leader>h", group = "hunk" },
  { "<leader>p", group = "pack" },
  { "<leader>t", group = "terminal" },
  { "<leader>u", group = "toggle" },
  { "<leader>x", group = "quickfix" },
})

require("conform").setup({
  formatters_by_ft = {
    lua = { "stylua" },
    sh = { "shfmt" },
    ["_"] = { "trim_whitespace", "trim_newlines" },
  },
  format_on_save = function()
    if not vim.g.autoformat then
      return nil
    end
    return { timeout_ms = 5000, lsp_format = "fallback" }
  end,
})

require("gitsigns").setup({
  current_line_blame = true,
  on_attach = function(buf)
    local gs = require("gitsigns")

    local map = function(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = buf, desc = desc })
    end

    -- stylua: ignore start
    map("n", "]c", function()
      if vim.wo.diff then
        vim.cmd.normal("]c", { bang = true })
      else
        gs.nav_hunk("next")
      end
    end, "Next Hunk")
    map("n", "[c", function()
      if vim.wo.diff then
        vim.cmd.normal("[c", { bang = true })
      else
        gs.nav_hunk("prev")
      end
    end, "Prev Hunk")

    map("v", "<leader>hs", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Stage Hunk")
    map("v", "<leader>hr", function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Reset Hunk")
    map("n", "<leader>hs", gs.stage_hunk, "Stage Hunk")
    map("n", "<leader>hr", gs.reset_hunk, "Reset Hunk")
    map("n", "<leader>hS", gs.stage_buffer, "Stage Buffer")
    map("n", "<leader>hR", gs.reset_buffer, "Reset Buffer")
    map("n", "<leader>hp", gs.preview_hunk, "Preview Hunk")
    map("n", "<leader>hi", gs.preview_hunk_inline, "Preview Hunk Inline")
    map("n", "<leader>hb", function() gs.blame_line({ full = true }) end, "Blame Line")
    map("n", "<leader>hB", function() gs.blame() end, "Blame Buffer")
    map("n", "<leader>hd", gs.diffthis, "Diff Against Index")
    map("n", "<leader>hD", function() gs.diffthis("@") end, "Diff Against HEAD")
    map("n", "<leader>ub", gs.toggle_current_line_blame, "Toggle Line Blame")
    map({ "o", "x" }, "ih", gs.select_hunk, "Select Hunk")
    -- stylua: ignore end
  end,
})

-- DAP
local dap = require("dap")
local dv = require("dap-view")
for _, file in ipairs(vim.api.nvim_get_runtime_file("dap/*.lua", true)) do
  local name = vim.fn.fnamemodify(file, ":t:r")
  local ok, spec = pcall(dofile, file)
  if ok and type(spec) == "table" then
    if spec.adapter then
      dap.adapters[name] = spec.adapter
    end
    for _, ft in ipairs(spec.filetypes or {}) do
      dap.configurations[ft] = dap.configurations[ft] or {}
      vim.list_extend(dap.configurations[ft], spec.configurations or {})
    end
  end
end
dv.setup()
-- stylua: ignore start
dap.listeners.before.attach["dap-view-config"] = function() dv.open() end
dap.listeners.before.launch["dap-view-config"] = function() dv.open() end
dap.listeners.before.event_terminated["dap-view-config"] = function() dv.close() end
dap.listeners.before.event_exited["dap-view-config"] = function() dv.close() end
-- stylua: ignore end

-- LSP
for _, file in ipairs(vim.api.nvim_get_runtime_file("lsp/*.lua", true)) do
  local server_name = vim.fn.fnamemodify(file, ":t:r")
  vim.lsp.enable(server_name)
end

-- Keymaps ====================================================================
local function toggle(label, get, set)
  return function()
    set(not get())
    vim.notify((get() and "Enabled " or "Disabled ") .. label)
  end
end

vim.keymap.set({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
vim.keymap.set({ "n", "x" }, "<down>", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
vim.keymap.set({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })
vim.keymap.set({ "n", "x" }, "<up>", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })

vim.keymap.set("n", "<c-d>", "<c-d>zz", { desc = "Scroll Down" })
vim.keymap.set("n", "<c-u>", "<c-u>zz", { desc = "Scroll Up" })
vim.keymap.set("n", "n", "nzzzv", { desc = "Next Result" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Prev Result" })

vim.keymap.set("x", "<", "<gv")
vim.keymap.set("x", ">", ">gv")

vim.keymap.set("i", ",", ",<c-g>u")
vim.keymap.set("i", ".", ".<c-g>u")
vim.keymap.set("i", ";", ";<c-g>u")

vim.keymap.set("n", "<esc>", "<cmd>nohlsearch<cr>")
vim.keymap.set("t", "<esc><esc>", "<c-\\><c-n>")

vim.keymap.set("n", "<leader>bd", "<cmd>bd<cr>")
vim.keymap.set("n", "<leader>w", "<cmd>w<cr>")
vim.keymap.set("n", "<leader>q", "<cmd>q<cr>")
vim.keymap.set("n", "<leader>-", "<c-w>s")
vim.keymap.set("n", "<leader>|", "<c-w>v")

vim.keymap.set("n", "<leader>pu", vim.pack.update, { desc = "Pack Update" })

-- stylua: ignore start
vim.keymap.set("n", "<leader>ud", toggle("diagnostics", vim.diagnostic.is_enabled, vim.diagnostic.enable), { desc = "Toggle Diagnostics" })
vim.keymap.set("n", "<leader>uw", toggle("wrap", function() return vim.o.wrap end, function(v) vim.o.wrap = v end), { desc = "Toggle Wrap" })
vim.keymap.set("n", "<leader>uf", toggle("autoformat", function() return vim.g.autoformat end, function(v) vim.g.autoformat = v end), { desc = "Toggle Autoformatting" })
-- stylua: ignore end

vim.keymap.set("n", "<leader>ut", function()
  vim.cmd.packadd("nvim.undotree")
  require("undotree").open()
end, { desc = "Undotree" })

vim.keymap.set("n", "<leader>xl", function()
  if vim.fn.getloclist(0, { winid = 0 }).winid ~= 0 then
    vim.cmd.lclose()
  else
    vim.cmd.lopen()
  end
end, { desc = "Location List" })

vim.keymap.set("n", "<leader>xq", function()
  if vim.fn.getqflist({ winid = 0 }).winid ~= 0 then
    vim.cmd.cclose()
  else
    vim.cmd.copen()
  end
end, { desc = "Quickfix List" })

vim.keymap.set("i", "<Tab>", function()
  if vim.lsp.inline_completion.get() then
    return ""
  elseif vim.fn.pumvisible() == 1 then
    return "<C-n>"
  elseif vim.snippet.active({ direction = 1 }) then
    return "<cmd>lua vim.snippet.jump(1)<cr>"
  else
    return "<Tab>"
  end
end, { expr = true })

vim.keymap.set("i", "<S-Tab>", function()
  if vim.fn.pumvisible() == 1 then
    return "<C-p>"
  elseif vim.snippet.active({ direction = -1 }) then
    return "<cmd>lua vim.snippet.jump(-1)<cr>"
  else
    return "<S-Tab>"
  end
end, { expr = true })

vim.keymap.set("i", "<CR>", function()
  return vim.fn.pumvisible() == 1 and "<C-y>" or "<CR>"
end, { expr = true })

local tmux = vim.env.TMUX ~= nil
local function tmux_navigate(key, dir)
  local win = vim.api.nvim_get_current_win()
  vim.cmd.wincmd(key)
  if tmux and vim.api.nvim_get_current_win() == win then
    vim.fn.system({ "tmux", "select-pane", "-" .. dir })
  end
end
for key, dir in pairs({ h = "L", j = "D", k = "U", l = "R" }) do
  vim.keymap.set({ "n", "t" }, "<C-" .. key .. ">", function()
    tmux_navigate(key, dir)
  end, { desc = "Navigate " .. dir })
end

for _, map in ipairs({
  { { "x", "o" }, "af", "@function.outer" },
  { { "x", "o" }, "if", "@function.inner" },
  { { "x", "o" }, "ac", "@class.outer" },
  { { "x", "o" }, "ic", "@class.inner" },
  { { "x", "o" }, "a?", "@conditional.outer" },
  { { "x", "o" }, "i?", "@conditional.inner" },
  { { "x", "o" }, "al", "@loop.outer" },
  { { "x", "o" }, "il", "@loop.inner" },
  { { "x", "o" }, "aa", "@parameter.outer" },
  { { "x", "o" }, "ia", "@parameter.inner" },
}) do
  vim.keymap.set(map[1], map[2], function()
    require("nvim-treesitter-textobjects.select").select_textobject(map[3], "textobjects")
  end, { desc = "Select " .. map[3] })
end
for _, map in ipairs({
  { { "n", "x", "o" }, "]f", "goto_next_start", "@function.outer" },
  { { "n", "x", "o" }, "[f", "goto_previous_start", "@function.outer" },
  { { "n", "x", "o" }, "]a", "goto_next_start", "@parameter.inner" },
  { { "n", "x", "o" }, "[a", "goto_previous_start", "@parameter.inner" },
}) do
  vim.keymap.set(map[1], map[2], function()
    require("nvim-treesitter-textobjects.move")[map[3]](map[4], "textobjects")
  end, { desc = "Move to " .. map[3] })
end

vim.keymap.set("n", "grf", function()
  require("conform").format({ lsp_format = "prefer" })
end, { desc = "Format" })

vim.keymap.set("n", "-", "<cmd>Oil<cr>", { desc = "Oil" })

vim.keymap.set("n", "<leader><leader>", "<cmd>FzfLua files<cr>", { desc = "Files" })
vim.keymap.set("n", "<leader>,", "<cmd>FzfLua buffers<cr>", { desc = "Buffers" })
vim.keymap.set("n", "<leader>/", "<cmd>FzfLua live_grep<cr>", { desc = "Grep" })
vim.keymap.set("n", "<leader>gs", "<cmd>FzfLua git_status<cr>", { desc = "Git Status" })
vim.keymap.set("n", "<leader>gc", "<cmd>FzfLua git_commits<cr>", { desc = "Git Commits" })
vim.keymap.set("n", "<leader>gC", "<cmd>FzfLua git_bcommits<cr>", { desc = "Git Buffer Commits" })
vim.keymap.set("n", "<leader>gb", "<cmd>FzfLua git_branches<cr>", { desc = "Git Branches" })

-- stylua: ignore start
vim.keymap.set("n", "<leader>dc", dap.continue, { desc = "Continue" })
vim.keymap.set("n", "<leader>dn", dap.step_over, { desc = "Step Over (next)" })
vim.keymap.set("n", "<leader>di", dap.step_into, { desc = "Step Into" })
vim.keymap.set("n", "<leader>do", dap.step_out, { desc = "Step Out" })
vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "Toggle Breakpoint" })
vim.keymap.set("n", "<leader>dB", function() dap.set_breakpoint(vim.fn.input("Breakpoint condition: ")) end, { desc = "Conditional Breakpoint" })
vim.keymap.set("n", "<leader>dr", dap.repl.toggle, { desc = "REPL" })
vim.keymap.set("n", "<leader>dl", dap.run_last, { desc = "Run Last" })
vim.keymap.set("n", "<leader>du", dv.toggle, { desc = "View Toggle" })
-- stylua: ignore end

-- Autocmds ===================================================================
local group = vim.api.nvim_create_augroup("config", { clear = true })

vim.api.nvim_create_autocmd("TextYankPost", {
  group = group,
  callback = function()
    vim.hl.on_yank()
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = group,
  callback = function(ev)
    if vim.bo[ev.buf].buftype ~= "" then
      return
    end
    local lang = vim.treesitter.language.get_lang(ev.match)
    if lang then
      pcall(require("nvim-treesitter").install, { lang })
    end
    pcall(vim.treesitter.start)
    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end,
})

vim.api.nvim_create_autocmd("LspAttach", {
  group = group,
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if not client then
      return
    end

    vim.keymap.set("n", "grd", vim.lsp.buf.definition, { desc = "vim.lsp.buf.definition()" })
    vim.keymap.set("n", "grD", vim.lsp.buf.declaration, { desc = "vim.lsp.buf.declaration()" })

    if client:supports_method("textDocument/completion") then
      vim.lsp.completion.enable(true, ev.data.client_id, ev.buf, { autotrigger = true })
    end
    if client:supports_method("textDocument/inlineCompletion") then
      vim.lsp.inline_completion.enable(true, { bufnr = ev.buf })
    end
    if client:supports_method("textDocument/codeLens") then
      vim.lsp.codelens.enable(true, { bufnr = ev.buf })
    end
    if client:supports_method("textDocument/inlayHint") then
      vim.keymap.set(
        "n",
        "<leader>uh",
        toggle("inlay hints", vim.lsp.inlay_hint.is_enabled, vim.lsp.inlay_hint.enable),
        { desc = "Toggle Inlay Hints" }
      )
    end
  end,
})

vim.api.nvim_create_autocmd("LspProgress", {
  group = group,
  callback = function(ev)
    local data = ev.data.params.value
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    local name = client and client.name or ""
    local msg = name .. ": " .. (data.title or "") .. (data.message and " " .. data.message or "")
    local status = data.kind == "end" and "success" or "running"
    vim.api.nvim_echo({ { msg } }, false, {
      kind = "progress",
      source = name,
      id = "lsp_progress_" .. ev.data.client_id,
      status = status,
      percent = data.percentage,
    })
  end,
})
