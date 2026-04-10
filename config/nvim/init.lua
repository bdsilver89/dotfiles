vim.pack.add({
  "https://github.com/tpope/vim-sleuth",
  "https://github.com/nvim-treesitter/nvim-treesitter",
  "https://github.com/nvim-treesitter/nvim-treesitter-textobjects",
  "https://github.com/neovim/nvim-lspconfig",
  "https://github.com/mason-org/mason.nvim",
  "https://github.com/mason-org/mason-lspconfig.nvim",
  "https://github.com/stevearc/oil.nvim",
  "https://github.com/ibhagwan/fzf-lua",
  "https://github.com/lewis6991/gitsigns.nvim",
})

vim.g.mapleader = " "

vim.o.autocomplete = true
vim.o.autoread = true
vim.o.breakindent = true
vim.opt.completeopt = { "menu", "menuone", "noselect", "popup", "fuzzy" }
vim.o.confirm = true
vim.o.cursorline = true
vim.o.foldexpr = "v:vim.treesitter.foldexpr()"
vim.o.foldlevel = 99
vim.o.foldmethod = "expr"
vim.o.ignorecase = true
vim.o.laststatus = 3
vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.o.number = true
vim.o.relativenumber = true
vim.o.scrolloff = 10
vim.opt.shortmess:append("c")
vim.o.signcolumn = "yes"
vim.o.smartcase = true
vim.o.smartindent = true
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.termguicolors = true
vim.o.timeoutlen = 300
vim.o.undofile = true
vim.o.updatetime = 250
vim.o.wrap = false

vim.schedule(function() vim.o.clipboard = "unnamedplus" end)
vim.cmd.colorscheme("catppuccin")

vim.o.statusline = table.concat({
  "%<%f %h%w%m%r",
  " %{% v:lua.require('vim._core.util').term_exitcode() %}",
  " %{% exists('b:gitsigns_head') ? ' '..b:gitsigns_head : '' %}",
  " %{% exists('b:gitsigns_status') && b:gitsigns_status != '' ? ' '..b:gitsigns_status : '' %}",
  "%=",
  " %{% luaeval('(package.loaded[''vim.lsp''] and vim.lsp.status()) or '''' ') %}",
  " %{% &showcmdloc == 'statusline' ? '%-10.S ' : '' %}",
  " %{% exists('b:keymap_name') ? '<'..b:keymap_name..'> ' : '' %}",
  " %{% &busy > 0 ? '◐ ' : '' %}",
  " %{% luaeval('(package.loaded[''vim.diagnostic''] and next(vim.diagnostic.count()) and vim.diagnostic.status() .. '' '') or '''' ') %}",
  " %{% &ruler ? ( &rulerformat == '' ? '%-14.(%l,%c%V%) %P' : &rulerformat ) : '' %}",
})

vim.diagnostic.config({
  severity_sort = true,
  underline = true,
  update_in_insert = false,
  virtual_lines = {
    current_line = true,
  },
  virtual_text = {
    current_line = false,
  },
})

local lsp_servers = {
  basedpyright = {},
  clangd = { mason = false },
  jdtls = {},
  lua_ls = {
    settings = {
      Lua = { workspace = { library = vim.api.nvim_get_runtime_file("lua", true) } },
    },
  },
  rust_analyzer = { mason = false },
}

require("nvim-treesitter-textobjects").setup({
  select = {
    lookahead = true,
  },
  move = {
    enable = true,
    set_jumps = true,
  },
})

require("mason").setup()

require("oil").setup({
  keymaps = {
    ["<C-h>"] = false,
  },
})

require("fzf-lua").setup({
  keymap = {
    fzf = {
      ["ctrl-q"] = "select-all+accept",
    },
  },
})

local mlsp_servers = {}
for server, opts in pairs(lsp_servers) do
  local use_mason = opts and opts.mason ~= false
  opts.mason = nil
  vim.lsp.config(server, opts)
  vim.lsp.enable(server)
  if use_mason then
    mlsp_servers[#mlsp_servers + 1] = server
  end
end
require("mason-lspconfig").setup({
  ensure_installed = mlsp_servers,
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
    map("n", "<leader>hd", gs.diffthis, "Diff Against Index")
    map("n", "<leader>hD", function() gs.diffthis("@") end, "Diff Against HEAD")
    map("n", "<leader>hQ", function() gs.setqflist("all") end, "Send to Quickfix")

    map("n", "<ledaer>ub", gs.toggle_current_line_blame, "Toggle Line Blame")

    map({ "o", "x" }, "ih", gs.select_hunk, "Select Hunk")
    -- stylua: ignore end
  end,
})

-- stylua: ignore start
vim.keymap.set({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
vim.keymap.set({ "n", "x" }, "<down>", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
vim.keymap.set({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })
vim.keymap.set({ "n", "x" }, "<up>", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })
-- stylua: ignore end

vim.keymap.set("n", "<esc>", "<cmd>nohlsearch<cr>")
vim.keymap.set("t", "<esc><esc>", "<c-\\><c-n>")

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

vim.keymap.set("n", "<leader>ud", function()
  vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end, { desc = "Toggle Diagnostics" })
vim.keymap.set("n", "<leader>uw", function()
  vim.o.wrap = not vim.o.wrap
end, { desc = "Toggle Wrap" })

vim.keymap.set("n", "<leader>ut", function()
  vim.cmd.packadd("nvim.undotree")
  require("undotree").open()
end, { desc = "Undotree" })

vim.keymap.set("n", "<leader>xl", function()
  if vim.fn.getloclist(0, { winid = 0 }).winid ~= 0 then vim.cmd.lclose() else vim.cmd.lopen() end
end, { desc = "Location List" })

vim.keymap.set("n", "<leader>xq", function()
  if vim.fn.getqflist({ winid = 0 }).winid ~= 0 then vim.cmd.cclose() else vim.cmd.copen() end
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

vim.keymap.set("n", "-", "<cmd>Oil<cr>", { desc = "Oil" })

-- stylua: ignore start
vim.keymap.set("n", "<leader><leader>", "<cmd>FzfLua files<cr>", { desc = "Files" })
vim.keymap.set("n", "<leader>,", "<cmd>FzfLua buffers<cr>", { desc = "Buffers" })
vim.keymap.set("n", "<leader>/", "<cmd>FzfLua live_grep<cr>", { desc = "Grep" })
-- stylua: ignore end

local tsto_select = require("nvim-treesitter-textobjects.select")
local tsto_move = require("nvim-treesitter-textobjects.move")
for _, map in ipairs({
  { { "x", "o" }, "af", "@function.outer" },
  { { "x", "o" }, "if", "@function.inner" },
  { { "x", "o" }, "ac", "@class.outer" },
  { { "x", "o" }, "ic", "@class.inner" },
  { { "x", "o" }, "aa", "@parameter.outer" },
  { { "x", "o" }, "ia", "@parameter.inner" },
}) do
  vim.keymap.set(map[1], map[2], function() tsto_select.select_texobject(map[3], "textobjects") end, { desc = "Select " .. map[3] })
end
for _, map in ipairs({
  { { "n", "x", "o" }, "]f", "goto_next_start", "@function.outer" },
  { { "n", "x", "o" }, "[f", "goto_previous_start", "@function.outer" },
  { { "n", "x", "o" }, "]c", "goto_next_start", "@class.outer" },
  { { "n", "x", "o" }, "[c", "goto_previous_start", "@class.outer" },
}) do
  vim.keymap.set(map[1], map[2], function() tsto_move[map[3]](map[4], "textobjects") end, { desc = "Move to " .. map[3] })
end

local group = vim.api.nvim_create_augroup("config", { clear = true })

vim.api.nvim_create_autocmd("TextYankPost", {
  group = group,
  callback = function()
    vim.hl.on_yank()
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
  desc = "Close with <q>",
  pattern = { "nvim-undotree", "git", "help", "man", "qf" },
  group = group,
  callback = function(ev)
    if ev.match ~= "help" or not vim.bo[ev.buf].modifiable then
      vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = ev.buf, silent = true })
    end
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = group,
  callback = function(ev)
    if vim.bo[ev.buf].buftype ~= "" then
      return
    end
    local lang = vim.treesitter.language.get_lang(ev.match)
    if lang and require("nvim-treesitter.parsers")[lang] then
      pcall(require("nvim-treesitter").install, { lang })
    end
    pcall(vim.treesitter.start)
    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end,
})

vim.api.nvim_create_autocmd("LspAttach", {
  group = group,
  callback = function(ev)
    local client_id = ev.data.client_id
    local client = vim.lsp.get_client_by_id(client_id)
    if not client then
      return
    end

    local map = function(lhs, rhs, desc)
      vim.keymap.set("n", lhs, rhs, { buffer = ev.buf, desc = desc })
    end

    map("grd", vim.lsp.buf.definition, "vim.lsp.buf.definition()")
    map("grD", vim.lsp.buf.declaration, "vim.lsp.buf.declaration()")
    map("grf", vim.lsp.buf.format, "vim.lsp.buf.format()")

    if client:supports_method("textDocument/completion") then
      vim.lsp.completion.enable(true, client_id, ev.buf, { autotrigger = true })
    end
    if client:supports_method("textDocument/inlineCompletion") then
      vim.lsp.inline_completion.enable(true, { bufnr = ev.buf })
    end
    if client:supports_method("textDocument/documentHighlight") then
      local hl_group = vim.api.nvim_create_augroup("lsp_document_highlight_" .. ev.buf, { clear = true })
      vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
        buffer = ev.buf,
        group = hl_group,
        callback = vim.lsp.buf.document_highlight,
      })
      vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "BufLeave" }, {
        buffer = ev.buf,
        group = hl_group,
        callback = vim.lsp.buf.clear_references,
      })
      vim.api.nvim_create_autocmd("LspDetach", {
        buffer = ev.buf,
        group = hl_group,
        callback = function(detach_ev)
          if detach_ev.data.client_id == client_id then
            vim.lsp.buf.clear_references()
            vim.api.nvim_del_augroup_by_id(hl_group)
          end
        end,
      })
    end
    if client:supports_method("textDocument/codeLens") then
      vim.lsp.codelens.enable(true, { bufnr = ev.buf })
    end
    if client:supports_method("textDocument/inlayHint") then
      map("<leader>uh", function()
        vim.lsp.inlay_hint.enable(
          not vim.lsp.inlay_hint.is_enabled({ bufnr = ev.buf })
        )
      end, "Toggle Inlay Hints")
    end
  end,
})

vim.api.nvim_create_autocmd("LspProgress", {
  desc = "Redraw statusline on LSP progress",
  callback = function()
    vim.cmd.redrawstatus()
  end,
})
