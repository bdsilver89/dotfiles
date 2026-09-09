-- ============================================================================
-- Options
-- ============================================================================
vim.loader.enable()

vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.o.breakindent = true
vim.o.cmdheight = 0
vim.o.confirm = true
vim.o.cursorline = true
vim.o.expandtab = true
vim.o.fillchars = "eob: ,foldopen:▾,foldclose:▸,foldsep: "
vim.o.foldlevel = 99
vim.o.foldmethod = "expr"
vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.o.ignorecase = true
vim.o.inccommand = "split"
vim.o.laststatus = 3
vim.o.list = true
vim.o.listchars = "tab:» ,trail:·,nbsp:␣"
vim.o.number = true
vim.o.pumheight = 10
vim.o.relativenumber = true
vim.o.scrolloff = 8
vim.o.shiftwidth = 2
vim.o.sidescrolloff = 8
vim.o.signcolumn = "yes"
vim.o.smartcase = true
vim.o.smartindent = true
vim.o.softtabstop = 2
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.tabstop = 2
vim.o.termguicolors = true
vim.o.timeoutlen = 300
vim.o.undofile = true
vim.o.updatetime = 250
vim.o.virtualedit = "block"
vim.o.wrap = false

-- stylua: ignore
vim.schedule(function() vim.o.clipboard = "unnamedplus" end)

vim.diagnostic.config({
  severity_sort = true,
  virtual_text = { current_line = true },
  float = { border = "rounded", source = "if_many" },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = " ",
      [vim.diagnostic.severity.WARN] = " ",
      [vim.diagnostic.severity.HINT] = " ",
      [vim.diagnostic.severity.INFO] = " ",
    },
  },
  jump = {
    on_jump = function(_, bufnr)
      vim.diagnostic.open_float({ bufnr = bufnr, scope = "cursor", focus = false })
    end,
  },
})

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

vim.keymap.set("x", "<", "<gv")
vim.keymap.set("x", ">", ">gv")

vim.keymap.set("t", "<esc><esc>", "<c-\\><c-n>")

vim.keymap.set("i", ",", ",<c-g>u")
vim.keymap.set("i", ".", ".<c-g>u")
vim.keymap.set("i", ";", ";<c-g>u")

vim.keymap.set("n", "<leader>xd", vim.diagnostic.setqflist)
vim.keymap.set("n", "<leader>xb", vim.diagnostic.setloclist)
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
  pattern = {
    "checkhealth",
    "dap-float",
    "dbout",
    "fugitive",
    "fugitiveblame",
    "gitsigns-blame",
    "help",
    "neotest-output",
    "neotest-output-panel",
    "neotest-summary",
    "qf",
  },
  callback = function(ev)
    vim.bo[ev.buf].buflisted = false
    vim.schedule(function()
      vim.keymap.set("n", "q", function()
        vim.cmd("close")
        pcall(vim.api.nvim_buf_delete, ev.buf, { force = true })
      end, {
        buffer = ev.buf,
        silent = true,
        desc = "Quit buffer",
      })
    end)
  end,
})

-- ============================================================================
-- Plugins
-- ============================================================================
vim.cmd.packadd("nvim.difftool")
vim.cmd.packadd("nvim.undotree")

require("vim._core.ui2").enable({})

vim.api.nvim_create_autocmd("PackChanged", {
  group = group,
  callback = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    if kind ~= "install" and kind ~= "update" then
      return
    end
    if name == "telescope-fzf-native.nvim" and vim.fn.executable("make") == 1 then
      vim.system({ "make" }, { cwd = ev.data.path }):wait()
    elseif name == "LuaSnip" and vim.fn.executable("make") == 1 then
      vim.system({ "make", "install_jsregexp" }, { cwd = ev.data.path }):wait()
    elseif name == "nvim-treesitter" then
      if not ev.data.active then
        vim.cmd.packadd("nvim-treesitter")
      end
      vim.cmd("TSUpdate")
    end
  end,
})

local function gh(repo)
  return "https://github.com/" .. repo
end

-- Colorscheme ----------------------------------------------------------------
vim.pack.add({ { src = gh("catppuccin/nvim"), name = "catppuccin" } })
require("catppuccin").setup({
  integrations = {
    mini = { enabled = true },
  },
})
vim.cmd.colorscheme("catppuccin")

-- Treesitter -----------------------------------------------------------------
vim.pack.add({ gh("nvim-treesitter/nvim-treesitter") })

-- stylua: ignore
local parsers = {
  "bash", "c", "cmake", "cpp", "diff", "html", "java", "javascript", "jsdoc", "json", "json5", "lua", "luadoc",
  "make", "markdown", "markdown_inline", "ninja", "python", "query", "regex", "rust", "vim", "vimdoc", "xml", "yaml",
}

require("nvim-treesitter").install(parsers)

vim.api.nvim_create_autocmd("FileType", {
  group = group,
  -- stylua: ignore
  callback = function(ev)
    local buf, filetype = ev.buf, ev.match
    local lang = vim.treesitter.language.get_lang(filetype)
    if not lang then return end
    if not vim.treesitter.language.add(lang) then return end
    vim.treesitter.start(buf, lang)
    if vim.treesitter.query.get(lang, "indents") ~= nil then
      vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end
  end,
})

-- LSP ------------------------------------------------------------------------
local servers = {
  basedpyright = {},
  clangd = {},
  tsc = {},
  jdtls = {},
  rust_analyzer = {},
  lua_ls = {
    settings = {
      Lua = {
        runtime = { version = "LuaJIT" },
        workspace = { library = { vim.env.VIMRUNTIME } },
        diagnostics = { global = { "vim" } },
      },
    },
  },
}
vim.pack.add({
  gh("neovim/nvim-lspconfig"),
  gh("mason-org/mason.nvim"),
  gh("mason-org/mason-lspconfig.nvim"),
  gh("WhoIsSethDaniel/mason-tool-installer.nvim"),
})

require("mason").setup({})
require("mason-lspconfig").setup({ automatic_enable = false })

local ensure_installed = vim.tbl_keys(servers)
vim.list_extend(ensure_installed, {
  "stylua",
})

require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

for name, opts in pairs(servers) do
  vim.lsp.config(name, opts)
  vim.lsp.enable(name)
end

vim.api.nvim_create_autocmd("LspAttach", {
  group = group,
  -- stylua: ignore
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if not client then return end

    local function map(lhs, rhs, desc)
      vim.keymap.set("n", lhs, rhs, { desc = desc, buffer = ev.buf })
    end

    map("grn", vim.lsp.buf.rename, "Rename")
    map("gra", vim.lsp.buf.code_action, "Code action")
    map("grD", vim.lsp.buf.declaration, "Goto declaration")
    map("grx", vim.lsp.codelens.run, "Codelens")

    if client:supports_method("textDocument/inlayHint", ev.buf) then
      map("<leader>uh", function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = ev.buf }))
      end, "Toggle inlay hints")
    end
  end,
})

-- Formatting -----------------------------------------------------------------
vim.pack.add({ gh("stevearc/conform.nvim") })
require("conform").setup({
  formatters_by_ft = {
    lua = { "stylua" },
  },
  default_format_opts = {
    lsp_format = "fallback",
  },
  -- stylua: ignore
  format_on_save = function(bufnr)
    if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then return end
    return { timeout_ms = 500, lsp_format = "fallback" }
  end,
})
vim.g.disable_autoformat = false
vim.api.nvim_create_user_command("FormatToggle", function(args)
  if args.bang then
    vim.b.disable_autoformat = not vim.b.disable_autoformat
    vim.notify("Buffer autoformat: " .. (vim.b.disable_autoformat and "OFF" or "ON"))
  else
    vim.g.disable_autoformat = not vim.g.disable_autoformat
    vim.notify("Global autoformat: " .. (vim.g.disable_autoformat and "OFF" or "ON"))
  end
end, { desc = "Toggle autoformat", bang = true })
vim.keymap.set("n", "<leader>f", function()
  require("conform").format({ async = true })
end, { desc = "Format buffer" })
vim.keymap.set("n", "<leader>uf", "<cmd>FormatToggle<cr>")
vim.keymap.set("n", "<leader>uF", "<cmd>FormatToggle!<cr>")

-- Linting --------------------------------------------------------------------
-- TODO: linting

-- Language-specific ----------------------------------------------------------
vim.g.db_ui_use_nerd_fonts = 1
vim.g.db_ui_show_database_icons = 1
vim.pack.add({
  gh("tpope/vim-dadbod"),
  gh("kristijanhusak/vim-dadbod-ui"),
  gh("kristijanhusak/vim-dadbod-completion"),
  gh("mfussenegger/nvim-jdtls"),
})

-- Completion/Snippets --------------------------------------------------------
vim.pack.add({
  { src = gh("L3MON4D3/LuaSnip"), version = vim.version.range("2.*") },
  gh("rafamadriz/friendly-snippets"),
})
require("luasnip.loaders.from_vscode").lazy_load()
require("luasnip").setup({})

vim.pack.add({ { src = gh("saghen/blink.cmp"), version = vim.version.range("1.*") } })
require("blink.cmp").setup({
  keymap = {
    ["<cr>"] = { "accept", "fallback" },
    ["<c-\\>"] = { "hide", "fallback" },
    ["<c-n>"] = { "select_next", "show" },
    ["<c-p>"] = { "select_prev" },
    ["<tab>"] = { "select_next", "snippet_forward", "fallback" },
    ["<s-tab>"] = { "select_prev", "snippet_backward", "fallback" },
    ["<c-b>"] = { "scroll_documentation_up", "fallback" },
    ["<c-f>"] = { "scroll_documentation_down", "fallback" },
  },
  completion = {
    documentation = {
      auto_show = true,
      auto_show_delay_ms = 500,
    },
  },
  sources = {
    default = { "lsp", "path", "snippets", "buffer" },
    per_filetype = {
      sql = { "dadbod" },
    },
    providers = {
      dadbod = {
        name = "Dadbod",
        module = "vim_dadbod_completion.blink",
      },
    },
  },
  fuzzy = { implementation = "lua" },
  signature = { enabled = true },
})

-- Picker ---------------------------------------------------------------------
local telescope_plugins = {
  gh("nvim-lua/plenary.nvim"),
  gh("nvim-telescope/telescope.nvim"),
  gh("nvim-telescope/telescope-ui-select.nvim"),
}
if vim.fn.executable("make") == 1 then
  table.insert(telescope_plugins, gh("nvim-telescope/telescope-fzf-native.nvim"))
end
vim.pack.add(telescope_plugins)

require("telescope").setup({
  extensions = {
    ["ui-select"] = { require("telescope.themes").get_dropdown() },
  },
})
pcall(require("telescope").load_extension, "fzf")
pcall(require("telescope").load_extension, "ui-select")

local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "Search help" })
vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "Search keymaps" })
vim.keymap.set("n", "<leader>sf", builtin.find_files, { desc = "Search Files" })
vim.keymap.set("n", "<leader>ss", builtin.builtin, { desc = "Search builtin" })
vim.keymap.set({ "n", "v" }, "<leader>sw", builtin.grep_string, { desc = "Search current word" })
vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "Search grep" })
vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "Search diagnostics" })
vim.keymap.set("n", "<leader>sr", builtin.resume, { desc = "Search resume" })
vim.keymap.set("n", "<leader>s.", builtin.oldfiles, { desc = "Search recent files" })
vim.keymap.set("n", "<leader>sc", builtin.commands, { desc = "Search commands" })
vim.keymap.set("n", "<leader>sb", builtin.buffers, { desc = "Search buffers" })
vim.keymap.set("n", "<leader>st", "<cmd>TodoTelescope<cr>", { desc = "Search TODO" })

vim.keymap.set("n", "<leader>gb", builtin.git_branches, { desc = "Git branches" })
vim.keymap.set("n", "<leader>gl", builtin.git_commits, { desc = "Git commits" })
vim.keymap.set("n", "<leader>gs", builtin.git_status, { desc = "Git status" })

vim.api.nvim_create_autocmd("LspAttach", {
  group = group,
  callback = function(ev)
    local function map(lhs, rhs, desc)
      vim.keymap.set("n", lhs, rhs, { desc = desc, buffer = ev.buf })
    end
    map("grr", builtin.lsp_references, "Goto references")
    map("gri", builtin.lsp_implementations, "Goto implementation")
    map("grd", builtin.lsp_definitions, "Goto definition")
    map("gO", builtin.lsp_document_symbols, "Open document symbols")
    map("gW", builtin.lsp_dynamic_workspace_symbols, "Open workspace symbols")
    map("grt", builtin.lsp_type_definitions, "Goto type definition")
  end,
})

-- Git ------------------------------------------------------------------------
vim.pack.add({
  gh("tpope/vim-fugitive"),
  gh("lewis6991/gitsigns.nvim"),
  gh("pwntester/octo.nvim"),
})

vim.keymap.set("n", "<leader>gb", "<cmd>Git blame<cr>", { desc = "Git blame" })

local gitsigns = require("gitsigns")
gitsigns.setup({
  current_line_blame = true,
  -- stylua: ignore
  on_attach = function(bufnr)
    -- navigation
    vim.keymap.set("n", "]c", function()
      if vim.wo.diff then
        vim.cmd.normal({ "]c", bang = true })
      else
        gitsigns.nav_hunk("next")
      end
    end, { desc = "Next change", buf = bufnr })

    vim.keymap.set("n", "[c", function()
      if vim.wo.diff then
        vim.cmd.normal({ "[c", bang = true })
      else
        gitsigns.nav_hunk("prev")
      end
    end, { desc = "Prev change", buf = bufnr })

    vim.keymap.set("v", "<leader>hs", function() gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end,
      { desc = "Stage hunk", buf = bufnr })
    vim.keymap.set("v", "<leader>hr", function() gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end,
      { desc = "Reset hunk", buf = bufnr })
    vim.keymap.set("n", "<leader>hs", gitsigns.stage_hunk, { desc = "Stage hunk", buf = bufnr })
    vim.keymap.set("n", "<leader>hr", gitsigns.reset_hunk, { desc = "Reset hunk", buf = bufnr })
    vim.keymap.set("n", "<leader>hS", gitsigns.stage_buffer, { desc = "Stage buffer", buf = bufnr })
    vim.keymap.set("n", "<leader>hR", gitsigns.reset_buffer, { desc = "Reset buffer", buf = bufnr })
    vim.keymap.set("n", "<leader>hp", gitsigns.preview_hunk, { desc = "Preview hunk", buf = bufnr })
    vim.keymap.set("n", "<leader>hi", gitsigns.preview_hunk_inline, { desc = "Preview hunk inline", buf = bufnr })
    vim.keymap.set("n", "<leader>hb", gitsigns.blame_line, { desc = "Blame line", buf = bufnr })
    vim.keymap.set("n", "<leader>hB", gitsigns.blame, { desc = "Blame buffer", buf = bufnr })
    vim.keymap.set("n", "<leader>hd", gitsigns.diffthis, { desc = "Diff against index", buf = bufnr })
    vim.keymap.set("n", "<leader>hD", function() gitsigns.diffthis("~") end,
      { desc = "Diff against last commit", buf = bufnr })
    vim.keymap.set("n", "<leader>hQ", function() gitsigns.setqflist("all") end,
      { desc = "Diff all hunks to quickfix", buf = bufnr })
    vim.keymap.set("n", "<leader>hq", gitsigns.setqflist, { desc = "Diff buffer hunks to quickfix", buf = bufnr })
    vim.keymap.set({ "o", "x" }, "ih", gitsigns.select_hunk, { desc = "inside hunk", buf = bufnr })
  end
,
})

require("octo").setup({
  picker = "telescope",
  enable_builtin = true,
})
vim.keymap.set("n", "<leader>gi", "<cmd>Octo issue list<cr>", { desc = "List issues" })
vim.keymap.set("n", "<leader>gp", "<cmd>Octo pr list<cr>", { desc = "List PRs" })
vim.keymap.set("n", "<leader>gd", "<cmd>Octo discussion list<cr>", { desc = "List discussions" })
vim.keymap.set("n", "<leader>gn", "<cmd>Octo notification list<cr>", { desc = "List notifications" })

-- Debugging ------------------------------------------------------------------
vim.pack.add({
  gh("mfussenegger/nvim-dap"),
  gh("igorlfs/nvim-dap-view"),
})
local dap, dv = require("dap"), require("dap-view")
dv.setup({})

-- stylua: ignore start
dap.listeners.before.initialize["dap-view-hooks"] = function() dv.open() end
dap.listeners.after.event_terminated["dap-view-hooks"] = function() dv.close() end
dap.listeners.after.event_exited["dap-view-hooks"] = function() dv.close() end
-- stylua: ignore end

-- TODO: debugging adapters
-- TODO: debugging keymaps

-- Testing --------------------------------------------------------------------
-- TODO: testing
vim.pack.add({
  gh("nvim-neotest/nvim-nio"),
  gh("nvim-neotest/neotest"),
  gh("nvim-neotest/neotest-python"),
})
local neotest = require("neotest")
neotest.setup({
  adapters = {
    require("neotest-python"),
  },
})

-- stylua: ignore start
vim.keymap.set("n", "<leader>tc", function() neotest.run.run() end, { desc = "Run nearest" })
vim.keymap.set("n", "<leader>tf", function() neotest.run.run(vim.fn.expand("%")) end, { desc = "Run file" })
vim.keymap.set("n", "<leader>ts", function() neotest.summary.toggle() end, { desc = "Toggle summary" })
vim.keymap.set("n", "<leader>to", function() neotest.output_panel.toggle() end, { desc = "Toggle output" })
-- stylua: ignore end

-- Misc -----------------------------------------------------------------------
vim.pack.add({
  gh("tpope/vim-sleuth"),
  gh("tpope/vim-dispatch"),
  gh("christoomey/vim-tmux-navigator"),
})

vim.pack.add({ gh("lukas-reineke/indent-blankline.nvim") })
require("ibl").setup({})

vim.pack.add({ gh("j-hui/fidget.nvim") })
require("fidget").setup({})

vim.pack.add({ gh("folke/which-key.nvim") })
require("which-key").setup({
  delay = 0,
  spec = {
    { "<leader>b", group = "Buffer" },
    { "<leader>c", group = "Code" },
    { "<leader>d", group = "Debug" },
    { "<leader>g", group = "Git" },
    { "<leader>h", group = "Hunk" },
    { "<leader>s", group = "Search" },
    { "<leader>t", group = "Tet" },
    { "<leader>u", group = "Settings" },
    { "<leader>x", group = "Diagnostics" },
  },
})

vim.pack.add({ gh("folke/todo-comments.nvim") })
require("todo-comments").setup({ signs = false })

vim.pack.add({ gh("nvim-mini/mini.nvim") })
require("mini.icons").setup()
MiniIcons.mock_nvim_web_devicons()
MiniIcons.tweak_lsp_kind()

require("mini.pairs").setup()
require("mini.surround").setup()

local statusline = require("mini.statusline")
statusline.setup()
statusline.section_location = function()
  return "%2l:%-2v"
end
