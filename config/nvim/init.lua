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

vim.diagnostic.config({
  severity_sort = true,
  underline = true,
  update_in_insert = false,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "",
      [vim.diagnostic.severity.WARN] = "",
      [vim.diagnostic.severity.HINT] = "",
      [vim.diagnostic.severity.INFO] = "",
    },
  },
  virtual_text = true,
})

pcall(function()
  require("vim._core.ui2").enable()
end)

local augroup = vim.api.nvim_create_augroup("config", { clear = true })

-- Plugins ====================================================================
vim.pack.add({
  "https://github.com/tpope/vim-sleuth",
  "https://github.com/catppuccin/nvim",
  { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
  "https://github.com/neovim/nvim-lspconfig",
  "https://github.com/mason-org/mason.nvim",
  "https://github.com/mason-org/mason-lspconfig.nvim",
  "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim",
  "https://github.com/stevearc/conform.nvim",
  "https://github.com/lewis6991/gitsigns.nvim",
  "https://github.com/stevearc/oil.nvim",
  "https://github.com/ibhagwan/fzf-lua",
  "https://github.com/mfussenegger/nvim-dap",
  "https://github.com/igorlfs/nvim-dap-view",
  "https://github.com/theHamsta/nvim-dap-virtual-text",
  "https://github.com/mfussenegger/nvim-dap-python",
  "https://github.com/mfussenegger/nvim-jdtls",
})

require("catppuccin").setup({ flavour = "macchiato" })
vim.cmd.colorscheme("catppuccin")

-- Mason / tools ==============================================================
require("mason").setup()
require("mason-tool-installer").setup({
  -- stylua: ignore
  ensure_installed = {
    "lua-language-server", "clangd", "rust-analyzer", "basedpyright", "bash-language-server",
    "json-lsp", "yaml-language-server", "vtsls", "eslint-lsp", "jdtls", -- servers
    "stylua", "ruff", "clang-format", "shfmt", "prettierd", -- formatters
    "codelldb", "debugpy", "java-debug-adapter", "java-test", -- debug adapters
  },
})

-- Treesitter =================================================================
require("nvim-treesitter").setup()

-- LSP ========================================================================
vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      diagnostics = { globals = { "vim" } },
      workspace = {
        checkThirdParty = false,
        library = { vim.env.VIMRUNTIME },
      },
      telemetry = { enable = false },
    },
  },
})

require("mason-lspconfig").setup({
  -- stylua: ignore
  ensure_installed = {
    "lua_ls", "clangd", "rust_analyzer", "basedpyright", "bashls", "jsonls", "yamlls", "vtsls", "eslint",
  },
  automatic_enable = { exclude = { "jdtls" } },
})

-- Formatting =================================================================
local prettier = { "prettierd", "prettier", stop_after_first = true }
require("conform").setup({
  -- stylua: ignore
  formatters_by_ft = {
    lua = { "stylua" }, python = { "ruff_format", "ruff_organize_imports" },
    c = { "clang-format" }, cpp = { "clang-format" }, sh = { "shfmt" }, bash = { "shfmt" },
    rust = { lsp_format = "prefer" }, javascript = prettier, javascriptreact = prettier,
    typescript = prettier, typescriptreact = prettier, json = prettier, jsonc = prettier,
    yaml = prettier, css = prettier, html = prettier, markdown = prettier,
    ["_"] = { "trim_whitespace", "trim_newlines" },
  },
  format_on_save = function()
    if vim.g.autoformat then
      return { timeout_ms = 3000, lsp_format = "fallback" }
    end
  end,
})

-- Git ========================================================================
require("gitsigns").setup({
  current_line_blame = true,
  on_attach = function(buf)
    local gs = require("gitsigns")

    local map = function(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = buf, desc = desc })
    end

    -- stylua: ignore start
    map("n", "]c", function()
      if vim.wo.diff then vim.cmd.normal({ "]c", bang = true }) else gs.nav_hunk("next") end
    end, "Next Hunk")
    map("n", "[c", function()
      if vim.wo.diff then vim.cmd.normal({ "[c", bang = true }) else gs.nav_hunk("prev") end
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

-- File explorer / finder =====================================================
require("oil").setup({ keymaps = { ["<C-h>"] = false } })
require("fzf-lua").setup({ keymap = { fzf = { ["ctrl-q"] = "select-all+accept" } } })

-- Debugging ==================================================================
local dap = require("dap")
local dv = require("dap-view")

require("nvim-dap-virtual-text").setup({})
dv.setup()

-- stylua: ignore start
dap.listeners.before.attach["dap-view"] = function() dv.open() end
dap.listeners.before.launch["dap-view"] = function() dv.open() end
dap.listeners.before.event_terminated["dap-view"] = function() dv.close() end
dap.listeners.before.event_exited["dap-view"] = function() dv.close() end
-- stylua: ignore end

vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError" })
vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DiagnosticWarn" })
vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DiagnosticWarn", linehl = "Visual" })

local mason = vim.fn.stdpath("data") .. "/mason"

dap.adapters.codelldb = {
  type = "server",
  port = "${port}",
  executable = {
    command = mason .. "/packages/codelldb/extension/adapter/codelldb",
    args = { "--port", "${port}" },
  },
}

-- stylua: ignore
local codelldb_cfg = {
  {
    name = "Launch executable",
    type = "codelldb",
    request = "launch",
    program = function() return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file") end,
    cwd = "${workspaceFolder}",
    stopOnEntry = false,
  },
  {
    name = "Attach to process",
    type = "codelldb",
    request = "attach",
    pid = require("dap.utils").pick_process,
    cwd = "${workspaceFolder}",
  },
}
dap.configurations.c = codelldb_cfg
dap.configurations.cpp = codelldb_cfg
dap.configurations.rust = codelldb_cfg

require("dap-python").setup(mason .. "/packages/debugpy/venv/bin/python")

-- Java (jdtls + DAP) =========================================================
local function start_jdtls()
  local jdtls = require("jdtls")

  local root = vim.fs.root(0, {
    "mvnw",
    "gradlew",
    "settings.gradle",
    "settings.gradle.kts",
    "build.xml",
    "pom.xml",
    "build.gradle",
    "build.gradle.kts",
    ".git",
  }) or vim.fn.getcwd()

  local workspace = vim.fn.stdpath("cache") .. "/jdtls/workspace/" .. vim.fn.fnamemodify(root, ":p:h:t")

  local cmd = { mason .. "/bin/jdtls", "-data", workspace }
  for arg in string.gmatch(os.getenv("JDTLS_JVM_ARGS") or "", "%S+") do
    table.insert(cmd, "--jvm-arg=" .. arg)
  end

  local bundles = {}
  vim.list_extend(
    bundles,
    vim.split(
      vim.fn.glob(mason .. "/packages/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar"),
      "\n",
      { trimempty = true }
    )
  )
  vim.list_extend(
    bundles,
    vim.split(vim.fn.glob(mason .. "/packages/java-test/extension/server/*.jar"), "\n", { trimempty = true })
  )

  local extended = jdtls.extendedClientCapabilities
  extended.resolveAdditionalTextEditsSupport = true

  jdtls.start_or_attach({
    cmd = cmd,
    root_dir = root,
    capabilities = vim.lsp.protocol.make_client_capabilities(),
    init_options = {
      bundles = bundles,
      extendedClientCapabilities = extended,
    },
    settings = {
      java = {
        eclipse = { downloadSources = true },
        maven = { downloadSources = true },
        signatureHelp = { enabled = true },
        contentProvider = { preferred = "fernflower" },
        configuration = { updateBuildConfiguration = "interactive" },
        format = { enabled = false },
      },
    },
    on_attach = function(_, bufnr)
      jdtls.setup_dap({ hotcodereplace = "auto" })
      require("jdtls.dap").setup_dap_main_class_configs()

      local map = function(lhs, fn, desc)
        vim.keymap.set("n", lhs, fn, { buffer = bufnr, desc = desc })
      end
      map("<leader>jo", jdtls.organize_imports, "Organize Imports")
      map("<leader>jv", jdtls.extract_variable, "Extract Variable")
      map("<leader>jc", jdtls.extract_constant, "Extract Constant")
      map("<leader>jt", jdtls.test_nearest_method, "Test Nearest Method")
      map("<leader>jT", jdtls.test_class, "Test Class")
    end,
  })
end

vim.api.nvim_create_autocmd("FileType", {
  group = augroup,
  pattern = "java",
  callback = function()
    vim.bo.shiftwidth = 4
    vim.bo.tabstop = 4
    start_jdtls()
  end,
})

dap.configurations.java = {
  {
    name = "Attach to remote JVM",
    type = "java",
    request = "attach",
    hostName = function()
      return vim.fn.input("Host: ", "127.0.0.1")
    end,
    port = function()
      return tonumber(vim.fn.input("Port: ", "5005"))
    end,
  },
}

-- Lazygit (built-in floating terminal, no plugin) ============================
local lazygit = nil

local function lazygit_win_opts()
  local width = math.floor(vim.o.columns * 0.9)
  local height = math.floor(vim.o.lines * 0.9)
  return {
    relative = "editor",
    width = width,
    height = height,
    col = math.floor((vim.o.columns - width) / 2),
    row = math.floor((vim.o.lines - height) / 2),
    style = "minimal",
    border = "single",
  }
end

local function toggle_lazygit()
  if lazygit and vim.api.nvim_win_is_valid(lazygit.win) then
    vim.api.nvim_win_hide(lazygit.win)
    return
  end
  if lazygit and vim.api.nvim_buf_is_valid(lazygit.buf) then
    lazygit.win = vim.api.nvim_open_win(lazygit.buf, true, lazygit_win_opts())
    vim.cmd.startinsert()
    return
  end

  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, true, lazygit_win_opts())
  lazygit = { buf = buf, win = win }
  vim.fn.jobstart("lazygit", {
    term = true,
    on_exit = function()
      local state = lazygit
      lazygit = nil
      if state then
        pcall(vim.api.nvim_win_close, state.win, true)
        vim.schedule(function()
          pcall(vim.api.nvim_buf_delete, state.buf, { force = true })
        end)
      end
    end,
  })
  vim.cmd.startinsert()
end

vim.api.nvim_create_autocmd("VimResized", {
  group = augroup,
  callback = function()
    if lazygit and vim.api.nvim_win_is_valid(lazygit.win) then
      vim.api.nvim_win_set_config(lazygit.win, lazygit_win_opts())
    end
  end,
})

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

vim.keymap.set("n", "<leader>bd", "<cmd>bd<cr>", { desc = "Delete Buffer" })
vim.keymap.set("n", "<leader>w", "<cmd>w<cr>", { desc = "Write" })
vim.keymap.set("n", "<leader>q", "<cmd>q<cr>", { desc = "Quit" })
vim.keymap.set("n", "<leader>-", "<c-w>s", { desc = "Split Below" })
vim.keymap.set("n", "<leader>|", "<c-w>v", { desc = "Split Right" })
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Line Diagnostics" })

-- stylua: ignore start
vim.keymap.set("n", "<leader>ud", toggle("diagnostics", vim.diagnostic.is_enabled, vim.diagnostic.enable), { desc = "Toggle Diagnostics" })
vim.keymap.set("n", "<leader>uw", toggle("wrap", function() return vim.o.wrap end, function(v) vim.o.wrap = v end), { desc = "Toggle Wrap" })
vim.keymap.set("n", "<leader>uf", toggle("autoformat", function() return vim.g.autoformat end, function(v) vim.g.autoformat = v end), { desc = "Toggle Autoformat" })
-- stylua: ignore end

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
  if vim.fn.pumvisible() == 1 then
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

vim.keymap.set("n", "grf", function()
  require("conform").format({ lsp_format = "prefer" })
end, { desc = "Format" })

vim.keymap.set("n", "-", "<cmd>Oil<cr>", { desc = "Oil" })

vim.keymap.set("n", "<leader><leader>", "<cmd>FzfLua files<cr>", { desc = "Files" })
vim.keymap.set("n", "<leader>,", "<cmd>FzfLua buffers<cr>", { desc = "Buffers" })
vim.keymap.set("n", "<leader>/", "<cmd>FzfLua live_grep<cr>", { desc = "Grep" })
vim.keymap.set("n", "<leader>fh", "<cmd>FzfLua help_tags<cr>", { desc = "Help" })
vim.keymap.set("n", "<leader>fd", "<cmd>FzfLua diagnostics_document<cr>", { desc = "Diagnostics" })
vim.keymap.set("n", "<leader>gs", "<cmd>FzfLua git_status<cr>", { desc = "Git Status" })
vim.keymap.set("n", "<leader>gc", "<cmd>FzfLua git_commits<cr>", { desc = "Git Commits" })
vim.keymap.set("n", "<leader>gC", "<cmd>FzfLua git_bcommits<cr>", { desc = "Git Buffer Commits" })
vim.keymap.set("n", "<leader>gb", "<cmd>FzfLua git_branches<cr>", { desc = "Git Branches" })

if vim.fn.executable("lazygit") == 1 then
  vim.keymap.set("n", "<leader>gg", toggle_lazygit, { desc = "Lazygit" })
end

-- stylua: ignore start
vim.keymap.set("n", "<leader>dc", dap.continue, { desc = "Continue" })
vim.keymap.set("n", "<leader>dn", dap.step_over, { desc = "Step Over" })
vim.keymap.set("n", "<leader>di", dap.step_into, { desc = "Step Into" })
vim.keymap.set("n", "<leader>do", dap.step_out, { desc = "Step Out" })
vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "Toggle Breakpoint" })
vim.keymap.set("n", "<leader>dB", function() dap.set_breakpoint(vim.fn.input("Breakpoint condition: ")) end, { desc = "Conditional Breakpoint" })
vim.keymap.set("n", "<leader>dr", dap.repl.toggle, { desc = "REPL" })
vim.keymap.set("n", "<leader>dl", dap.run_last, { desc = "Run Last" })
vim.keymap.set("n", "<leader>du", dv.toggle, { desc = "View Toggle" })
-- stylua: ignore end

-- Autocmds ===================================================================
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup,
  callback = function()
    vim.hl.on_yank()
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = augroup,
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
  group = augroup,
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if not client then
      return
    end

    vim.keymap.set("n", "grd", vim.lsp.buf.definition, { buffer = ev.buf, desc = "Definition" })
    vim.keymap.set("n", "grD", vim.lsp.buf.declaration, { buffer = ev.buf, desc = "Declaration" })

    if client:supports_method("textDocument/completion") then
      vim.lsp.completion.enable(true, ev.data.client_id, ev.buf, { autotrigger = true })
    end
    if client:supports_method("textDocument/codeLens") then
      vim.lsp.codelens.enable(true, { bufnr = ev.buf })
    end
    if client:supports_method("textDocument/inlayHint") then
      vim.keymap.set(
        "n",
        "<leader>uh",
        toggle("inlay hints", vim.lsp.inlay_hint.is_enabled, vim.lsp.inlay_hint.enable),
        { buffer = ev.buf, desc = "Toggle Inlay Hints" }
      )
    end
  end,
})

vim.api.nvim_create_autocmd("LspProgress", {
  group = augroup,
  callback = function(ev)
    local data = ev.data.params.value
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    local name = client and client.name or ""
    local msg = name .. ": " .. (data.title or "") .. (data.message and " " .. data.message or "")
    vim.api.nvim_echo({ { msg } }, false, {
      kind = "progress",
      source = name,
      id = "lsp_progress_" .. ev.data.client_id,
      status = data.kind == "end" and "success" or "running",
      percent = data.percentage,
    })
  end,
})

-- Commands ===================================================================
vim.api.nvim_create_user_command("PackUpdate", function(opts)
  if opts.args ~= "" then
    vim.pack.update(vim.split(opts.args, "%s+", { trimempty = true }))
  else
    vim.pack.update()
  end
end, { desc = "Update plugins", nargs = "*" })
