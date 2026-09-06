-- ============================================================================
-- Options
-- ============================================================================
vim.loader.enable()

vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0

vim.o.autocomplete = true
vim.o.breakindent = true
vim.o.complete = ".,w,b,u,o"
vim.o.cmdheight = 0
vim.o.completeopt = "menu,menuone,noselect,noinsert,popup,fuzzy"
vim.o.confirm = true
vim.o.cursorline = true
vim.o.expandtab = true
vim.o.exrc = true
vim.o.fillchars = "eob: "
vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.o.foldlevel = 99
vim.o.foldmethod = "expr"
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
vim.o.showmode = false
vim.o.signcolumn = "yes"
vim.o.smartcase = true
vim.o.softtabstop = 2
vim.o.splitbelow = true
vim.o.splitkeep = "screen"
vim.o.splitright = true
vim.o.tabstop = 2
vim.o.termguicolors = true
vim.o.timeoutlen = 300
vim.o.undofile = true
vim.o.updatetime = 250
vim.o.virtualedit = "block"
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
end)

vim.diagnostic.config({
  update_in_insert = false,
  severity_sort = true,
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

-- ============================================================================
-- Plugins
-- ============================================================================
vim.pack.add({
  { src = "https://github.com/catppuccin/nvim", name = "catppuccin" },
  "https://github.com/nvim-treesitter/nvim-treesitter",
  "https://github.com/nvim-treesitter/nvim-treesitter-textobjects",
  "https://github.com/neovim/nvim-lspconfig",
  "https://github.com/mason-org/mason.nvim",
  "https://github.com/mason-org/mason-lspconfig.nvim",
  "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim",
  "https://github.com/ibhagwan/fzf-lua",
  "https://github.com/nvim-mini/mini.nvim",
  "https://github.com/lewis6991/gitsigns.nvim",
  "https://github.com/folke/which-key.nvim",

  "https://github.com/tpope/vim-sleuth",
  "https://github.com/tpope/vim-fugitive",
  "https://github.com/tpope/vim-dispatch",
  "https://github.com/vim-test/vim-test",
  "https://github.com/christoomey/vim-tmux-navigator",
})

require("vim._core.ui2").enable()

vim.cmd.packadd("nvim.undotree")

vim.g["test#strategy"] = "dispatch"

require("catppuccin").setup()
vim.cmd.colorscheme("catppuccin")

local tsparsers = {
  "bash",
  "c",
  "cmake",
  "cpp",
  "diff",
  "dockerfile",
  "git_config",
  "git_rebase",
  "gitcommit",
  "gitignore",
  "hcl",
  "html",
  "java",
  "javascript",
  "jsdoc",
  "json",
  "json5",
  "lua",
  "luap",
  "luadoc",
  "make",
  "markdown",
  "markdown_inline",
  "ninja",
  "printf",
  "query",
  "regex",
  "ron",
  "rst",
  "ruby",
  "rust",
  "scala",
  "scss",
  "terraform",
  "toml",
  "tsx",
  "typescript",
  "vim",
  "vimdoc",
  "xml",
  "yaml",
}

require("nvim-treesitter").install(tsparsers)

require("nvim-treesitter-textobjects").setup({
  select = {
    lookahead = true,
  },
  move = {
    set_jumps = true,
  },
})

local servers = {
  bashls = {},
  clangd = { mason = false },
  rust_analyzer = { mason = false },
  lua_ls = {
    settings = {
      runtime = { version = "LuaJIT" },
      Lua = {
        workspace = {
          checkThirdParty = false,
          library = { vim.env.VIMRUNTIME },
        },
        diagnostics = { globals = { "vim" } },
      },
    },
  },
}
local ensure_installed = {}
for name, server in pairs(servers) do
  if server.mason ~= false then
    table.insert(ensure_installed, name)
  end
end
vim.list_extend(ensure_installed, {
  "stylua",
})

require("mason").setup({})
require("mason-lspconfig").setup({ automatic_enable = false })
require("mason-tool-installer").setup({
  ensure_installed = ensure_installed,
})

for name, server in pairs(servers) do
  server.mason = nil
  vim.lsp.config(name, server)
  vim.lsp.enable(name)
end

vim.schedule(function()
  local fzf = require("fzf-lua")
  fzf.config.defaults.keymap.fzf["ctrl-q"] = "select-all+accept"
  fzf.setup({ ui_select = {} })
end)

vim.schedule(function()
  local icons = require("mini.icons")
  icons.mock_nvim_web_devicons()
  icons.tweak_lsp_kind()

  require("mini.pairs").setup()
  require("mini.surround").setup()
  require("mini.bufremove").setup()
  require("mini.indentscope").setup()

  local statusline = require("mini.statusline")
  statusline.setup({})
  statusline.section_location = function()
    return "%2l:%-2v"
  end
end)

require("which-key").setup({})

vim.schedule(function()
  require("gitsigns").setup({
    current_line_blame = true,
    on_attach = function(bufnr)
      local gs = require("gitsigns")

      vim.keymap.set("n", "]c", function()
        if vim.wo.diff then
          vim.cmd.normal({ "]c", bang = true })
        else
          gs.nav_hunk("next")
        end
      end, { desc = "Next change", buf = bufnr })

      vim.keymap.set("n", "[c", function()
        if vim.wo.diff then
          vim.cmd.normal({ "[c", bang = true })
        else
          gs.nav_hunk("prev")
        end
      end, { desc = "Previous change", buf = bufnr })

      vim.keymap.set("v", "<leader>hs", function()
        gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
      end, { desc = "Stage hunk", buf = bufnr })
      vim.keymap.set("v", "<leader>hr", function()
        gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
      end, { desc = "Reset hunk", buf = bufnr })

      vim.keymap.set("n", "<leader>hs", gs.stage_hunk, { desc = "Stage hunk", buf = bufnr })
      vim.keymap.set("n", "<leader>hr", gs.reset_hunk, { desc = "Reset hunk", buf = bufnr })
      vim.keymap.set("n", "<leader>hS", gs.stage_buffer, { desc = "Stage buffer", buf = bufnr })
      vim.keymap.set("n", "<leader>hr", gs.reset_buffer, { desc = "Reset buffer", buf = bufnr })
      vim.keymap.set("n", "<leader>hp", gs.preview_hunk, { desc = "Preview hunk", buf = bufnr })
      vim.keymap.set("n", "<leader>hi", gs.preview_hunk_inline, { desc = "Preview hunk inline", buf = bufnr })
      vim.keymap.set("n", "<leader>hb", function()
        gs.blame_line({ full = true })
      end, { desc = "Blame line", buf = bufnr })
      vim.keymap.set("n", "<leader>hd", gs.diffthis, { desc = "Diff against index", buf = bufnr })
      vim.keymap.set("n", "<leader>hD", function()
        gs.diffthis("~")
      end, { desc = "Diff against last commit", buf = bufnr })
      vim.keymap.set("n", "<leader>hQ", function()
        gs.setqflist("all")
      end, { desc = "All hunk to quickfix", buf = bufnr })
      vim.keymap.set("n", "<leader>hq", gs.setqflist, { desc = "File hunks to quickfix", buf = bufnr })

      vim.keymap.set({ "o", "x" }, "ih", gs.select_hunk, { desc = "Inside hunk", buf = bufnr })
    end,
  })
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

vim.keymap.set("n", "<leader>q", "<cmd>q<cr>")
vim.keymap.set("n", "<leader>w", "<cmd>w<cr>")
vim.keymap.set("n", "<leader>bd", "<cmd>lua MiniBufremove.delete()<cr>")
vim.keymap.set("n", "<leader>bD", "<cmd>lua MiniBufremove.delete(0, true)<cr>")

vim.keymap.set("x", "<", "<gv")
vim.keymap.set("x", ">", ">gv")

vim.keymap.set("t", "<esc><esc>", "<c-\\><c-n>")

vim.keymap.set({ "i", "s" }, "<tab>", function()
  if vim.fn.pumvisible() == 1 then
    return "<c-n>"
  elseif vim.snippet.active({ direction = 1 }) then
    vim.snippet.jump(1)
  else
    return "<tab>"
  end
end, { expr = true, silent = true })

vim.keymap.set({ "i", "s" }, "<s-tab>", function()
  if vim.fn.pumvisible() == 1 then
    return "<c-p>"
  elseif vim.snippet.active({ direction = -1 }) then
    vim.snippet.jump(-1)
  else
    return "<s-tab>"
  end
end, { expr = true, silent = true })

vim.keymap.set("i", "<cr>", function()
  if vim.fn.pumvisible() == 1 then
    return "<c-y>"
  else
    return "<cr>"
  end
end, { expr = true })

local select = {
  ["ak"] = { query = "@block.outer", desc = "Select around block" },
  ["ik"] = { query = "@block.inner", desc = "Select inside block" },
  ["ac"] = { query = "@class.outer", desc = "Select around class" },
  ["ic"] = { query = "@class.inner", desc = "Select inside class" },
  ["a?"] = { query = "@conditional.outer", desc = "Select around conditional" },
  ["i?"] = { query = "@conditional.inner", desc = "Select inside conditional" },
  ["af"] = { query = "@function.outer", desc = "Select around function" },
  ["if"] = { query = "@function.inner", desc = "Select inside function" },
  ["ao"] = { query = "@loop.outer", desc = "Select around loop" },
  ["io"] = { query = "@loop.inner", desc = "Select inside loop" },
  ["aa"] = { query = "@parameter.outer", desc = "Select around argument" },
  ["ia"] = { query = "@parameter.inner", desc = "Select inside argument" },
}

local move = {
  goto_next_start = {
    ["]k"] = { query = "@block.outer", desc = "Next block start" },
    ["]f"] = { query = "@function.outer", desc = "Next function start" },
    ["]a"] = { query = "@parameter.outer", desc = "Next parameter start" },
  },
  goto_next_end = {
    ["]K"] = { query = "@block.outer", desc = "Next block end" },
    ["]F"] = { query = "@function.outer", desc = "Next function end" },
    ["]A"] = { query = "@parameter.outer", desc = "Next parameter end" },
  },
  goto_previous_start = {
    ["[k"] = { query = "@block.outer", desc = "Previous block start" },
    ["[f"] = { query = "@function.outer", desc = "Previous function start" },
    ["[a"] = { query = "@parameter.outer", desc = "Previous parameter start" },
  },
  goto_previous_end = {
    ["[K"] = { query = "@block.outer", desc = "Previous block end" },
    ["[F"] = { query = "@function.outer", desc = "Previous function end" },
    ["[A"] = { query = "@parameter.outer", desc = "Previous parameter end" },
  },
}

local swap = {
  swap_next = {
    [">K"] = { query = "@block.outer", desc = "Swap next block" },
    [">F"] = { query = "@function.outer", desc = "Swap next function" },
    [">A"] = { query = "@parameter.outer", desc = "Swap next parameter" },
  },
  swap_previous = {
    ["<K"] = { query = "@block.outer", desc = "Swap previous block" },
    ["<F"] = { query = "@function.outer", desc = "Swap previous function" },
    ["<A"] = { query = "@parameter.outer", desc = "Swap previous parameter" },
  },
}

for keys, opts in pairs(select) do
  vim.keymap.set({ "x", "o" }, keys, function()
    require("nvim-treesitter-textobjects.select").select_textobject(opts.query, "textobjects")
  end, { desc = opts.desc })
end

for dir, mappings in pairs(move) do
  for key, opts in pairs(mappings) do
    vim.keymap.set({ "n", "x", "o" }, key, function()
      require("nvim-treesitter-textobjects.move")[dir](opts.query)
    end, { desc = opts.desc })
  end
end

for dir, mappings in pairs(swap) do
  for key, opts in pairs(mappings) do
    vim.keymap.set({ "n", "x", "o" }, key, function()
      require("nvim-treesitter-textobjects.swap")[dir](opts.query)
    end, { desc = opts.desc })
  end
end

vim.keymap.set("n", "<leader>fb", "<cmd>FzfLua buffers sort_mru=true sort_lastused=true<cr>", { desc = "Buffers" })
vim.keymap.set("n", "<leader>ff", "<cmd>FzfLua files<cr>", { desc = "Files" })
vim.keymap.set("n", "<leader>fg", "<cmd>FzfLua git_files<cr>", { desc = "Files (git)" })
vim.keymap.set("n", "<leader>fr", "<cmd>FzfLua oldfiles<cr>", { desc = "Recent" })

vim.keymap.set("n", "<leader>gc", "<cmd>FzfLua git_commits<cr>", { desc = "Commits" })
vim.keymap.set("n", "<leader>gd", "<cmd>FzfLua git_diff<cr>", { desc = "Diff" })
vim.keymap.set("n", "<leader>gs", "<cmd>FzfLua git_status<cr>", { desc = "Status" })
vim.keymap.set("n", "<leader>gS", "<cmd>FzfLua git_stash<cr>", { desc = "Stash" })

vim.keymap.set("n", "<leader>s/", "<cmd>FzfLua search_history<cr>", { desc = "Search history" })
vim.keymap.set("n", "<leader>sb", "<cmd>FzfLua buffers<cr>", { desc = "Lines" })
vim.keymap.set("n", "<leader>sc", "<cmd>FzfLua command_history<cr>", { desc = "Command history" })
vim.keymap.set("n", "<leader>sC", "<cmd>FzfLua commands<cr>", { desc = "Commands" })
vim.keymap.set("n", "<leader>sd", "<cmd>FzfLua diagnostics_workspace<cr>", { desc = "Diagnostics" })
vim.keymap.set("n", "<leader>sD", "<cmd>FzfLua diagnostics_document<cr>", { desc = "Diagnostics buffer" })
vim.keymap.set("n", "<leader>sg", "<cmd>FzfLua live_grep<cr>", { desc = "Grep" })
vim.keymap.set("n", "<leader>sk", "<cmd>FzfLua keymaps<cr>", { desc = "Keymaps" })
vim.keymap.set("n", "<leader>sR", "<cmd>FzfLua resume<cr>", { desc = "Resume" })
vim.keymap.set({ "n", "x" }, "<leader>sw", "<cmd>FzfLua grep_cword<cr>", { desc = "Word" })

vim.keymap.set("n", "<leader><space>", "<leader>ff", { desc = "Files", remap = true })
vim.keymap.set("n", "<leader>,", "<leader>fb", { desc = "Buffers", remap = true })
vim.keymap.set("n", "<leader>:", "<leader>sc", { desc = "Command history", remap = true })
vim.keymap.set("n", "<leader>/", "<leader>sg", { desc = "Grep", remap = true })

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
  callback = function()
    local current_tab = vim.fn.tabpagenr()
    vim.cmd("tabdo wincmd =")
    vim.cmd("tabnext " .. current_tab)
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = { "text", "markdown", "gitcommit" },
  callback = function()
    vim.opt_local.spell = true
    vim.opt_local.wrap = true
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = "directory",
  callback = function(ev)
    vim.bo[ev.buf].bufhidden = "wipe"
    vim.keymap.set("n", "q", "<cmd>bd<cr>", { buffer = ev.buf })
  end,
})

local dir_icons_ns = vim.api.nvim_create_namespace("dir_icons")
vim.api.nvim_create_autocmd("User", {
  group = group,
  pattern = "DirReadPost",
  callback = function(ev)
    vim.api.nvim_buf_clear_namespace(ev.buf, dir_icons_ns, 0, -1)
    local devicons = require("nvim-web-devicons")
    for row, line in ipairs(vim.api.nvim_buf_get_lines(ev.buf, 0, -1, true)) do
      local icon, hl
      if line:sub(-1) == "/" then
        icon, hl = "", "Directory"
      else
        icon, hl = devicons.get_icon(line, nil, { default = true })
      end
      vim.api.nvim_buf_set_extmark(ev.buf, dir_icons_ns, row - 1, 0, {
        virt_text = { { icon .. " ", hl } },
        virt_text_pos = "inline",
      })
    end
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = {
    "checkhealth",
    "fugitive",
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

vim.api.nvim_create_autocmd("PackChanged", {
  desc = "Update plugins",
  group = group,
  callback = function(ev)
    if not (ev.data.kind == "install" or ev.data.kind == "update") then
      return
    end
    if ev.data.spec.name == "nvim-treesitter" then
      require("nvim-treesitter").install(tsparsers)
      require("nvim-treesitter").update()
    end
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  desc = "Attach treesitter",
  group = group,
  callback = function(ev)
    local buf = ev.buf
    local filetype = ev.match
    local language = vim.treesitter.language.get_lang(filetype)
    if not language then
      return
    end

    if not vim.treesitter.language.add(language) then
      return
    end

    vim.treesitter.start(buf, language)

    if vim.treesitter.query.get(language, "indents") ~= nil then
      vim.bo[buf].indentexpr = function()
        return require("nvim-treesitter").indentexpr()
      end
    end
  end,
})

vim.api.nvim_create_autocmd("LspAttach", {
  group = group,
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if not client then
      return
    end

    local function map(lhs, rhs, opts, mode)
      opts = type(opts) == "string" and { desc = opts } or opts
      opts.buffer = ev.buf
      vim.keymap.set(mode or "n", lhs, rhs, opts)
    end

    map("gd", "<cmd>FzfLua lsp_definitions<cr>", "Goto definition")
    map("gD", "<cmd>FzfLua lsp_declarations<cr>", "Goto declaration")
    map("grr", "<cmd>FzfLua lsp_references<cr>", "References")
    map("gri", "<cmd>FzfLua lsp_implementations<cr>", "Implementation")
    map("grt", "<cmd>FzfLua lsp_typedefs<cr>", "Goto type definition")
    map("gO", "<cmd>FzfLua lsp_document_symbols<cr>", "Symbols (document)")
    map("gW", "<cmd>FzfLua lsp_workspace_symbols<cr>", "Symbols (workspace)")
    map("gra", "<cmd>FzfLua lsp_code_actions<cr>", "Code actions")

    if client:supports_method("textDocument/completion") then
      vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = false })
    end

    if client:supports_method("textDocument/formatting") then
      vim.keymap.set("n", "<leader>cf", function()
        vim.lsp.buf.format({ bufnr = ev.buf })
      end, { buffer = ev.buf })
    end

    if client:supports_method("textDocument/documentColor") then
      vim.lsp.document_color.enable(true, { bufnr = ev.buf })
    end

    if client:supports_method("textDocument/documentHighlight") then
      local hlaugroup = vim.api.nvim_create_augroup("config_lsphighlight", { clear = false })
      vim.api.nvim_create_autocmd({ "CursorHold", "InsertLeave" }, {
        group = hlaugroup,
        buffer = ev.buf,
        callback = vim.lsp.buf.document_highlight,
      })
      vim.api.nvim_create_autocmd({ "CursorMoved", "InsertLeave", "BufLeave" }, {
        group = hlaugroup,
        buffer = ev.buf,
        callback = vim.lsp.buf.clear_references,
      })
    end
  end,
})
