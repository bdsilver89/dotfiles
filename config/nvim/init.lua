-- Globals ====================================================================

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Options ====================================================================

vim.opt.breakindent = true
vim.opt.clipboard = vim.env.SSH_TTY and "" or "unnamedplus"
vim.opt.confirm = true
vim.opt.cursorline = true
vim.opt.expandtab = true
vim.opt.foldlevel = 99
vim.opt.foldmethod = "indent"
vim.opt.ignorecase = true
vim.opt.laststatus = 3
vim.opt.linebreak = true
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣", }
vim.opt.mouse = "a"
vim.opt.number = true
vim.opt.pumblend = 10
vim.opt.pumheight = 10
vim.opt.relativenumber = true
vim.opt.scrolloff = 4
vim.opt.shiftwidth = 2
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
})

require("vim._core.ui2").enable({
  enable = true,
  msg = {
    target = "msg"
  },
})

-- Plugins ====================================================================

vim.pack.add({
  "https://github.com/tpope/vim-sleuth",
  "https://github.com/christoomey/vim-tmux-navigator",
  "https://github.com/nvim-lua/plenary.nvim",
  "https://github.com/nvim-tree/nvim-web-devicons",
  { src = "https://github.com/catppuccin/nvim", name = "catppuccin" },
  "https://github.com/nvim-treesitter/nvim-treesitter",
  "https://github.com/neovim/nvim-lspconfig",
  "https://github.com/saghen/blink.cmp",
  "https://github.com/mason-org/mason.nvim",
  "https://github.com/mason-org/mason-lspconfig.nvim",
  "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim",
  "https://github.com/nvim-telescope/telescope.nvim",
  "https://github.com/lewis6991/gitsigns.nvim",
  "https://github.com/nvim-lualine/lualine.nvim",
  "https://github.com/folke/which-key.nvim",
  "https://github.com/stevearc/oil.nvim",
})
if vim.fn.executable("make") == 1 then
  vim.pack.add({ "https://github.com/nvim-telescope/telescope-fzf-native.nvim" })
end

require("catppuccin").setup({})
vim.cmd.colorscheme("catppuccin")

-- Treesitter
local languages = {
  "bash",
  "c",
  "cmake",
  "cpp",
  "diff",
  "dockerfile",
  "java",
  "javascript",
  "json",
  "lua",
  "luadoc",
  "luap",
  "make",
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
  "html",
  "vim",
  "vimdoc",
  "xml",
  "yaml",
}
local filetypes = {}
for _, lang in ipairs(languages) do
  for _, ft in ipairs(vim.treesitter.language.get_filetypes(lang)) do
    filetypes[#filetypes+1] = ft
  end
end
require("nvim-treesitter").install(languages)

-- Blink.cmp
require("blink.cmp").setup({
  completion = {
    documentation = {
      auto_show = true,
    },
    ghost_text = {
      enabled = true,
    },
  },
  fuzzy = { implementation = "lua" },
  keymap = {
    preset = "enter",
    ["<C-y>"] = { "select_and_accept" },
  },
  sources = {
    default = { "lsp", "path", "snippets", "buffer" },
  },
})

-- Mason + LSP
require("mason").setup()
require("mason-lspconfig").setup()
require("mason-tool-installer").setup({
  ensure_installed = {
    "lua_ls",
    "stylua",

    "clangd",

    "pyright",

    "jdtls",
  },
})

-- Telescope
require("telescope").setup({
  extensions = {
    fzf = {}
  },
})
if pcall(require, "fzf_lib") then
  require("telescope").load_extension("fzf")
end

-- Git
require("gitsigns").setup({
  current_line_blame = true,
  on_attach = function(buf)
    local gs = require("gitsigns")
    local function map(mode, l, r, desc)
      vim.keymap.set(mode, l, r, { buffer = buf, desc = desc })
    end

    -- stylua: ignore start
    map("n", "]h", function() gs.nav_hunk("next") end, "Next Hunk")
    map("n", "[h", function() gs.nav_hunk("prev") end, "Prev Hunk")
    map("n", "<leader>hs", gs.stage_hunk, "Stage Hunk")
    map("n", "<leader>hr", gs.reset_hunk, "Reset Hunk")
    map("x", "<leader>hs", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Stage Hunk")
    map("x", "<leader>hr", function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Reset Hunk")
    map("n", "<leader>hS", gs.stage_buffer, "Stage Buffer")
    map("n", "<leader>hu", gs.undo_stage_hunk, "Undo Stage Hunk")
    map("n", "<leader>hR", gs.reset_buffer, "Reset Buffer")
    map("n", "<leader>hp", gs.preview_hunk, "Preview Hunk")
    map("n", "<leader>hi", gs.preview_hunk_inline, "Preview Hunk Inline")
    map("n", "<leader>hb", function() gs.blame_line({ full = true }) end, "Blame Line")
    map("n", "<leader>hd", gs.diffthis, "Diff This")
    map("n", "<leader>hD", function() gs.diffthis("~") end, "Diff This ~")
    map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "Inside Hunk")
    -- stylua: ignore end
  end,
})

-- Lualine
require("lualine").setup({
  options = {
    section_separators = { left = "", right = "" },
    component_separators = { left = "", right = "" },
  },
})

-- Which-Key
require("which-key").setup({
  spec = {
    { "<leader>b", group = "Buffer" },
    { "<leader>g", group = "Git" },
    { "<leader>h", group = "Hunk" },
    { "<leader>q", group = "Session/Quit" },
    { "<leader>u", group = "UI" },
    { "<leader>x", group = "Diagnostics" },
  },
})

-- Oil
require("oil").setup({})

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

vim.keymap.set("n", "<leader>bd", "<cmd>bd<cr>")
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

vim.keymap.set("n", "-", "<cmd>Oil<cr>", { desc = "File Explorer" })

-- stylua: ignore start
local pickers = require("telescope.builtin")
vim.keymap.set("n", "<leader><space>", pickers.find_files, { desc = "Find Files" })
vim.keymap.set("n", "<leader>/", pickers.live_grep, { desc = "Grep" })
vim.keymap.set("n", "<leader>,", pickers.buffers, { desc = "Buffers" })
vim.keymap.set("n", "<leader>:", pickers.command_history, { desc = "Command History" })
vim.keymap.set("n", "<leader>\"", pickers.registers, { desc = "Registers" })
vim.keymap.set("n", "<leader>s", pickers.resume, { desc = "Resume Last Picker" })
vim.keymap.set("n", "<leader>?", pickers.help_tags, { desc = "Help Tags" })
vim.keymap.set("n", "<leader>xd", pickers.diagnostics, { desc = "Diagnostics" })
vim.keymap.set("n", "<leader>gc", pickers.git_commits, { desc = "Commits" })
vim.keymap.set("n", "<leader>gC", pickers.git_bcommits, { desc = "Buffer Commits" })
vim.keymap.set("n", "<leader>gb", pickers.git_branches, { desc = "Branches" })
vim.keymap.set("n", "<leader>gs", pickers.git_status, { desc = "Status" })
vim.keymap.set("n", "<leader>gS", pickers.git_stash, { desc = "Stash" })
-- stylua: ignore end

-- Autocmds ===================================================================

local group = vim.api.nvim_create_augroup("config", { clear = true })

vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight on text yank",
  group = group,
  callback = function()
    vim.hl.on_yank()
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
  group = group,
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if not client then
      return
    end

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

    if client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
      vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
      vim.keymap.set("n", "<leader>uh", function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = ev.buf }))
      end, { desc = "Toggle Inlay Hints" })
    end
  end,
})

local progress_ids = {}
vim.api.nvim_create_autocmd("LspProgress", {
  group = group,
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if not client then
      return
    end

    local val = ev.data.params.value
    local msg = val.title or ""
    if val.message then
      msg = msg .. ": " .. val.message
    end
    if val.percentage then
      msg = string.format("%d%%: %s", val.percentage, msg)
    end
    msg = client.name .. " " .. msg

    local key = client.id .. ":" .. tostring(ev.data.params.token)
    local echo_opts = {
      kind = "progress",
      status = val.kind == "end" and "success" or "running",
      percent = val.percentage,
    }
    if progress_ids[key] then
      echo_opts.id = progress_ids[key]
    end

    local id = vim.api.nvim_echo({{ msg }}, true, echo_opts)
    if val.kind == "end" then
      progress_ids[key] = nil
    else
      progress_ids[key] = id
    end
  end
})
