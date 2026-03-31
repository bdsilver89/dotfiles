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
  "https://github.com/nvim-treesitter/nvim-treesitter-textobjects",
  "https://github.com/nvim-treesitter/nvim-treesitter-context",
  "https://github.com/nvim-mini/mini.nvim",
  "https://github.com/mason-org/mason.nvim",
  "https://github.com/ibhagwan/fzf-lua",
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
require("treesitter-context").setup()
require("nvim-treesitter-textobjects").setup({
  select = {
    lookahead = true,
  },
  move = {
    enable = true,
    set_jumps = true,
  },
})

-- Mini
require("mini.extra").setup()
require("mini.surround").setup()
-- require("mini.cmdline").setup()
require("mini.diff").setup({ view = { style = "sign" } })
require("mini.git").setup()
require("mini.indentscope").setup()
require("mini.bufremove").setup()
require("mini.tabline").setup()

local statusline = require("mini.statusline")
statusline.setup()
statusline.section_location = function() return "%2l:%-2v" end

require("mini.completion").setup({
  lsp_completion = {
    source_func = "omnifunc",
    auto_setup = false,
    process_items = function(items, base)
      return MiniCompletion.default_process_items(items, base, {
        kind_priority = { Text = -1, Snippet = 99 }
      })
    end,
  },
})
vim.lsp.config("*", { capabilities = MiniCompletion.get_lsp_capabilities() })

local clue = require("mini.clue")
clue.setup({
  clues = {
    { mode = "n", keys = "<leader>b", desc = "+Buffer" },
    { mode = "n", keys = "<leader>e", desc = "+Explore/Edit" },
    { mode = "n", keys = "<leader>f", desc = "+Find" },
    { mode = "n", keys = "<leader>g", desc = "+Git" },
    { mode = "n", keys = "<leader>h", desc = "+Hunk" },
    { mode = "n", keys = "<leader>u", desc = "+UI" },
    { mode = "n", keys = "<leader>q", desc = "+Session/Quit" },
    { mode = "n", keys = "<leader>x", desc = "+Diagnostics" },
    clue.gen_clues.builtin_completion(),
    clue.gen_clues.g(),
    clue.gen_clues.marks(),
    clue.gen_clues.registers(),
    clue.gen_clues.square_brackets(),
    clue.gen_clues.windows({ submode_resize = true }),
    clue.gen_clues.z(),
  },
  triggers = {
    { mode = { "n", "x" }, keys = "<leader>" },
    { mode = { "n", "x" }, keys = "[" },
    { mode = { "n", "x" }, keys = "]" },
    { mode = { "n", "x" }, keys = "g" },
    { mode = { "n", "x" }, keys = "'" },
    { mode = { "n", "x" }, keys = "`" },
    { mode = { "n", "x" }, keys = '"' },
    { mode = { "n", "x" }, keys = "s" },
    { mode = { "n", "x" }, keys = "z" },
    { mode = "i", keys = "<c-x>" },
    { mode = "n", keys = "<c-w>" },
  },
})

local hipatterns = require("mini.hipatterns")
hipatterns.setup({
  highlighters = {
    fixme = MiniExtra.gen_highlighter.words({ "FIXME", "Fixme", "fixme" }, "MiniHipatternsFixme"),
    hack = MiniExtra.gen_highlighter.words({ "HACK", "Hack", "hack" }, "MiniHipatternsHack"),
    todo = MiniExtra.gen_highlighter.words({ "TODO", "Todo", "todo" }, "MiniHipatternsTodo"),
    note = MiniExtra.gen_highlighter.words({ "NOTE", "Note", "note" }, "MiniHipatternsNote"),
    hex_color = hipatterns.gen_highlighter.hex_color(),
  },
})

local snippets = require("mini.snippets")
snippets.setup({
  snippets = {
    snippets.gen_loader.from_file(vim.fn.stdpath("config") .. "/snippets/global.json"),
    snippets.gen_loader.from_lang(),
  },
  mappings = {
    expand = "",
    jump_next = "",
    jump_prev = "",
    stop = "<C-c>",
  },
})
MiniSnippets.start_lsp_server()

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

-- LSP ========================================================================

local servers = {}
for _, path in ipairs(vim.api.nvim_get_runtime_file("lsp/*.lua", true)) do
  servers[#servers + 1] = vim.fn.fnamemodify(path, ":t:r")
end
vim.lsp.enable(servers)

vim.diagnostic.config({
  update_in_insert = false,
  severity_sort = true,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = " ",
      [vim.diagnostic.severity.WARN] = " ",
      [vim.diagnostic.severity.INFO] = " ",
      [vim.diagnostic.severity.HINT] = " ",
    },
  },
  virtual_text = true,
  virtual_lines = false,
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

local map_multistep = require("mini.keymap").map_multistep
map_multistep("i", "<Tab>", { "minisnippets_next", "pmenu_next" })
map_multistep("i", "<S-Tab>", { "minisnippets_prev", "pmenu_prev" })
map_multistep("i", "<CR>", { "pmenu_accept", "minipairs_cr" })

vim.keymap.set("n", "<leader>bd", "<cmd>lua MiniBufremove.delete()<cr>")
vim.keymap.set("n", "<leader>bD", "<cmd>lua MiniBufremove.delete(0, true)<cr>")
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
vim.keymap.set("n", "<leader>ho", MiniDiff.toggle_overlay, { desc = "Toggle Overlay" })
vim.keymap.set("n", "<leader>hr", function() MiniDiff.do_hunks(0, "reset") end, { desc = "Reset Hunk" })
vim.keymap.set("x", "<leader>hr", function() MiniDiff.do_hunks(0, "reset") end, { desc = "Reset Hunk" })
vim.keymap.set("n", "<leader>hR", function() MiniDiff.do_hunks(0, "reset", { all = true }) end, { desc = "Reset Buffer" })
vim.keymap.set("n", "<leader>hb", MiniGit.show_at_cursor, { desc = "Blame" })
vim.keymap.set("n", "<leader>hH", MiniGit.show_range_history, { desc = "Range History" })
vim.keymap.set("x", "<leader>hH", MiniGit.show_range_history, { desc = "Range History" })
-- stylua: ignore end

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

for _, map in ipairs({
  { { "x", "o" }, "af", "@function.outer" },
  { { "x", "o" }, "if", "@function.inner" },
  { { "x", "o" }, "ac", "@class.outer" },
  { { "x", "o" }, "ic", "@class.inner" },
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
  { { "n", "x", "o" }, "]c", "goto_next_start", "@class.outer" },
  { { "n", "x", "o" }, "[c", "goto_previous_start", "@class.outer" },
}) do
	local modes, lhs, fn, query = map[1], map[2], map[3], map[4]
	local qstr = (type(query) == "table") and table.concat(query, ",") or query
  vim.keymap.set(modes, lhs, function()
    require("nvim-treesitter-textobjects.move")[fn](query, "textobjects")
  end, { desc = "Move to " .. qstr })
end


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
    vim.keymap.set("n", "q", function()
      local buf = vim.api.nvim_get_current_buf()
      vim.cmd("bprevious")
      vim.api.nvim_buf_delete(buf, { force = true })
    end, opts)
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

vim.api.nvim_create_autocmd("LspAttach", {
  desc = "LSP setup",
  group = vim.api.nvim_create_augroup("config_lsp", { clear = true }),
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if not client then
      return
    end

    vim.bo[ev.buf].omnifunc = "v:lua.MiniCompletion.completefunc_lsp"

    -- stylua: ignore start
    vim.keymap.set("n", "grd", vim.lsp.buf.definition, { desc = "Definition", buffer = ev.buf })
    vim.keymap.set("n", "grD", vim.lsp.buf.declaration, { desc = "Declaration", buffer = ev.buf })
    vim.keymap.set("n", "grf", vim.lsp.buf.format, { desc = "Format", buffer = ev.buf })
    -- stylua: ignore end

    if client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
      local hl_group_name = "config_lsp_highlight"
      local hl_group = vim.api.nvim_create_augroup(hl_group_name, { clear = false })
      vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
        buffer = ev.buf,
        group = hl_group,
        callback = vim.lsp.buf.document_highlight,
      })
      vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
        buffer = ev.buf,
        group = hl_group,
        callback = vim.lsp.buf.clear_references,
      })
      vim.api.nvim_create_autocmd("LspDetach", {
        group = vim.api.nvim_create_augroup("config_lsp_detach", { clear = true }),
        callback = function(ev2)
          vim.lsp.buf.clear_references()
          vim.api.nvim_clear_autocmds({ group = hl_group_name, buffer = ev2.buf })
        end,
      })
    end

    if client:supports_method(vim.lsp.protocol.Methods.textDocument_codeLens) then
      vim.lsp.codelens.enable(true, { bufnr = ev.buf })
    end

    if client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
      vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
      vim.keymap.set("n", "<leader>uh", function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = ev.buf }))
      end, { desc = "Toggle Inlay Hints" })
    end
  end,
})
