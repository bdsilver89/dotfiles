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

require("vim._core.ui2").enable({
  enable = true,
  msg = {
    targets = {
      default = "cmd",
      progress = "msg",
    },
  },
})

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

-- Colorscheme ----------------------------------------------------------------
vim.pack.add({ { src = "https://github.com/catppuccin/nvim", name = "catppuccin" } })
require("catppuccin").setup({
  integrations = {
    mini = { enabled = true },
  },
})
vim.cmd.colorscheme("catppuccin")

-- Treesitter -----------------------------------------------------------------
vim.pack.add({
  "https://github.com/nvim-treesitter/nvim-treesitter",
  "https://github.com/nvim-treesitter/nvim-treesitter-textobjects",
  "https://github.com/windwp/nvim-ts-autotag",
})

-- stylua: ignore
local parsers = {
  "bash", "c", "cmake", "cpp", "diff", "html", "java", "javascript", "jsdoc", "json", "json5", "lua", "luadoc",
  "make", "markdown", "markdown_inline", "ninja", "python", "query", "regex", "rust", "vim", "vimdoc", "xml", "yaml",
}

require("nvim-treesitter").install(parsers)
require("nvim-ts-autotag").setup({})
require("nvim-treesitter-textobjects").setup({
  select = {
    lookahead = true,
  },
  move = {
    enable = true,
    set_jumps = true,
  },
})

local ts_modes = { select = { "x", "o" }, move = { "n", "x", "o" }, swap = "n" }
-- stylua: ignore
local textobjects = {
  { "ik", "select.select_textobject", "@block.inner", "Inside block" },
  { "ak", "select.select_textobject", "@block.outer", "Around block" },
  { "ic", "select.select_textobject", "@class.inner", "Inside class" },
  { "ac", "select.select_textobject", "@class.outer", "Around class" },
  { "if", "select.select_textobject", "@function.inner", "Inside function" },
  { "af", "select.select_textobject", "@function.outer", "Around function" },
  { "io", "select.select_textobject", "@loop.inner", "Inside loop" },
  { "ao", "select.select_textobject", "@loop.outer", "Around loop" },
  { "i?", "select.select_textobject", "@conditional.inner", "Inside conditional" },
  { "a?", "select.select_textobject", "@conditional.outer", "Around conditional" },
  { "ia", "select.select_textobject", "@parameter.inner", "Inside argument" },
  { "aa", "select.select_textobject", "@parameter.outer", "Around argument" },

  { "]k", "move.goto_next_start",     "@block.outer", "Next block start" },
  { "]f", "move.goto_next_start",     "@function.outer", "Next function start" },
  { "]a", "move.goto_next_start",     "@parameter.outer", "Next parameter start" },

  { "]K", "move.goto_next_end",       "@block.outer", "Next block end" },
  { "]F", "move.goto_next_end",       "@function.outer", "Next function end" },
  { "]a", "move.goto_next_end",       "@parameter.outer", "Next parameter end" },

  { "[k", "move.goto_previous_start", "@block.outer", "Previous block start" },
  { "[f", "move.goto_previous_start", "@function.outer", "Previous function start" },
  { "[a", "move.goto_previous_start", "@parameter.outer", "Previous parameter start" },

  { "[K", "move.goto_previous_end",   "@block.outer", "Previous block end" },
  { "[F", "move.goto_previous_end",   "@function.outer", "Previous function end" },
  { "[A", "move.goto_previous_end",   "@parameter.outer", "Previous parameter end" },

  { ">K", "swap.swap_next",           "@block.outer", "Swap next block" },
  { ">F", "swap.swap_next",           "@function.outer", "Swap next function" },
  { ">A", "swap.swap_next",           "@parameter.outer", "Swap next argument" },

  { "<K", "swap.swap_previous",       "@block.outer", "Swap previous block" },
  { "<F", "swap.swap_previous",       "@function.outer", "Swap previous function" },
  { "<A", "swap.swap_previous",       "@parameter.outer", "Swap previous argument" },
}
for _, spec in ipairs(textobjects) do
  local key, path, query, desc = unpack(spec)
  local mod, method = path:match("^(%w+)%.(.+)$")
  vim.keymap.set(ts_modes[mod], key, function()
    require("nvim-treesitter-textobjects." .. mod)[method](query)
  end, { desc = desc })
end

vim.api.nvim_create_autocmd("FileType", {
  group = group,
  -- stylua: ignore
  callback = function(ev)
    local buf, filetype = ev.buf, ev.match
    local lang = vim.treesitter.language.get_lang(filetype)

    if not lang then return end
    if not vim.treesitter.language.add(lang) then return end
    if not vim.api.nvim_buf_is_valid(buf) then return end

    vim.treesitter.start(buf, lang)
    if vim.treesitter.query.get(lang, "indents") ~= nil then
      vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end
  end,
})

-- Language-specific ----------------------------------------------------------
vim.pack.add({
  "https://github.com/mfussenegger/nvim-jdtls",
  "https://github.com/nanotee/sqls.nvim",
})
vim.cmd.packadd("sqls.nvim")

-- LSP ------------------------------------------------------------------------
local servers = {
  basedpyright = {},
  clangd = {},
  tsc = {},
  rust_analyzer = {},
  sqls = {
    cmd = { "sqls", "-config", vim.fn.expand("~/.config/sqls/config.yml") },
  },
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
  "https://github.com/neovim/nvim-lspconfig",
  "https://github.com/mason-org/mason.nvim",
  "https://github.com/mason-org/mason-lspconfig.nvim",
  "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim",
})

require("mason").setup({})
require("mason-lspconfig").setup({ automatic_enable = false })

local ensure_installed = vim.tbl_keys(servers)
vim.list_extend(ensure_installed, {
  "stylua",
  "codelldb",
  "jdtls",
  "java-debug-adapter",
})

require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

for name, opts in pairs(servers) do
  vim.lsp.config(name, opts)
  vim.lsp.enable(name)
end

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
vim.pack.add({ "https://github.com/stevearc/conform.nvim" })
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

-- Completion/Snippets --------------------------------------------------------
vim.pack.add({
  { src = "https://github.com/L3MON4D3/LuaSnip", version = vim.version.range("2.*") },
  "https://github.com/rafamadriz/friendly-snippets",
})
require("luasnip.loaders.from_vscode").lazy_load()
require("luasnip").setup({})

vim.pack.add({ { src = "https://github.com/saghen/blink.cmp", version = vim.version.range("1.*") } })
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
  },
  fuzzy = { implementation = "lua" },
  signature = { enabled = true },
})

-- Picker ---------------------------------------------------------------------
local telescope_plugins = {
  "https://github.com/nvim-lua/plenary.nvim",
  "https://github.com/nvim-telescope/telescope.nvim",
  "https://github.com/nvim-telescope/telescope-ui-select.nvim",
}
if vim.fn.executable("make") == 1 then
  table.insert(telescope_plugins, "https://github.com/nvim-telescope/telescope-fzf-native.nvim")
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
  "https://github.com/tpope/vim-fugitive",
  "https://github.com/lewis6991/gitsigns.nvim",
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

-- Debugging ------------------------------------------------------------------
vim.pack.add({
  "https://github.com/mfussenegger/nvim-dap",
  "https://github.com/igorlfs/nvim-dap-view",
})
local dap, dv = require("dap"), require("dap-view")
dv.setup({})

-- stylua: ignore start
dap.listeners.before.initialize["dap-view-hooks"] = function() dv.open() end
dap.listeners.after.event_terminated["dap-view-hooks"] = function() dv.close() end
dap.listeners.after.event_exited["dap-view-hooks"] = function() dv.close() end
-- stylua: ignore end

dap.adapters.codelldb = {
  type = "server",
  host = "localhost",
  port = "${port}",
  executable = {
    command = "codelldb",
    args = { "--port", "${port}" },
  },
}

local dap_utils = require("dap.utils")
for _, lang in ipairs({ "c", "cpp" }) do
  dap.configurations[lang] = {
    {
      type = "codelldb",
      request = "launch",
      name = "Launch file",
      program = function()
        return dap_utils.pick_file({ executables = true })
      end,
      args = function()
        return dap_utils.splitstr(vim.fn.input("Args: "))
      end,
      cwd = "${workspaceFolder}",
      stopOnEntry = false,
    },
    {
      type = "codelldb",
      request = "attach",
      name = "Attach to process",
      pid = dap_utils.pick_process,
    },
  }
end

dap.configurations.java = {
  {
    type = "java",
    request = "attach",
    name = "Attach to JVM (5005)",
    hostName = "127.0.0.1",
    port = 5005,
  },
}

-- stylua: ignore start
vim.keymap.set("n", "<leader>db", function() require("dap").toggle_breakpoint() end, { desc = "Toggle breakpoint" })
vim.keymap.set("n", "<leader>dc", function() require("dap").continue() end, { desc = "Continue" })
vim.keymap.set("n", "<leader>do", function() require("dap").step_over() end, { desc = "Step over" })
vim.keymap.set("n", "<leader>dO", function() require("dap").step_out() end, { desc = "Step out" })
vim.keymap.set("n", "<leader>di", function() require("dap").step_into() end, { desc = "Step into" })
-- stylua: ignore end

-- Testing --------------------------------------------------------------------
-- TODO: testing
vim.pack.add({
  "https://github.com/nvim-neotest/nvim-nio",
  "https://github.com/nvim-neotest/neotest",
  "https://github.com/nvim-neotest/neotest-python",
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
vim.keymap.set("n", "<leader>tF", function() neotest.run.run(vim.uv.cwd()) end, { desc = "Run all files" })
vim.keymap.set("n", "<leader>ts", function() neotest.summary.toggle() end, { desc = "Toggle summary" })
vim.keymap.set("n", "<leader>to", function() neotest.output_panel.toggle() end, { desc = "Toggle output" })
-- stylua: ignore end

-- Misc -----------------------------------------------------------------------
vim.pack.add({
  "https://github.com/tpope/vim-sleuth",
  "https://github.com/tpope/vim-dispatch",
  "https://github.com/christoomey/vim-tmux-navigator",
})

vim.pack.add({ "https://github.com/lukas-reineke/indent-blankline.nvim" })
require("ibl").setup({})

vim.pack.add({ "https://github.com/folke/which-key.nvim" })
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

vim.pack.add({ "https://github.com/folke/todo-comments.nvim" })
require("todo-comments").setup({ signs = false })

vim.pack.add({ "https://github.com/nvim-mini/mini.nvim" })
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
