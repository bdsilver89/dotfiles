-- Globals ====================================================================

vim.g.mapleader = " "
vim.g.maplolcaleader = " "

vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0

-- Options ====================================================================

vim.opt.autocomplete = true
vim.opt.autoread = true
vim.opt.breakindent = true
vim.opt.completeopt = { "menuone", "noselect", "popup", "fuzzy", "nearest" }
vim.opt.confirm = true
vim.opt.cursorline = true
vim.opt.diffopt:append("linematch:60")
vim.opt.expandtab = true
vim.opt.fillchars = { eob = " " }
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldlevel = 99
vim.opt.foldmethod = "expr"
vim.opt.ignorecase = true
vim.opt.indentexpr = "v:lua.vim.treesitter.indentexpr()"
vim.opt.laststatus = 3
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣", }
vim.opt.number = true
vim.opt.pumheight = 10
vim.opt.relativenumber = true
vim.opt.shiftwidth = 2
vim.opt.shortmess:append("cw")
vim.opt.signcolumn = "yes"
vim.opt.smartcase = true
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.tabstop = 2
vim.opt.timeoutlen = 300
vim.opt.undofile = true
vim.opt.undolevels = 10000
vim.opt.updatetime = 250
vim.opt.wrap = false

vim.schedule(function()
  vim.opt.clipboard = vim.env.SSH_TTY and "" or "unnamedplus"
  vim.cmd.colorscheme("catppuccin")
end)

vim.opt.statusline = table.concat({
  "%<%f %h%w%m%r",
  " %{% v:lua.require('vim._core.util').term_exitcode() %}",
  " %{% exists('b:gitsigns_head') ? ' '..b:gitsigns_head : '' %}",
  "%{% exists('b:gitsigns_status') && b:gitsigns_status != '' ? ' '..b:gitsigns_status : '' %}",
  "%=",
  "%{% luaeval('(package.loaded[''vim.lsp''] and vim.lsp.status()) or '''' ')%} ",
  "%{% &showcmdloc == 'statusline' ? '%-10.S ' : '' %}",
  "%{% exists('b:keymap_name') ? '<'..b:keymap_name..'> ' : '' %}",
  "%{% &busy > 0 ? '◐ ' : '' %}",
  "%{% luaeval('(package.loaded[''vim.diagnostic''] and next(vim.diagnostic.count()) and vim.diagnostic.status() .. '' '') or '''' ') %}",
  "%{% &ruler ? ( &rulerformat == '' ? '%-14.(%l,%c%V%) %P' : &rulerformat ) : '' %}",
})

require("vim._core.ui2").enable({
  enable = true,
})

-- Keymaps ====================================================================

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

vim.keymap.set("n", "-", "<cmd>Oil<cr>", { desc = "Oil" })

-- stylua: ignore start
vim.keymap.set("n", "<leader><leader>", "<cmd>FzfLua files<cr>", { desc = "Files" })
vim.keymap.set("n", "<leader>,", "<cmd>FzfLua buffers<cr>", { desc = "Buffers" })
vim.keymap.set("n", "<leader>/", "<cmd>FzfLua live_grep<cr>", { desc = "Grep" })
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
  desc = "Install treesitter",
  group = group,
  callback = function(ev)
    if vim.bo[ev.buf].buftype ~= "" then
      return
    end
    local lang = vim.treesitter.language.get_lang(ev.match)
    if lang and require("nvim-treesitter.parsers")[lang] then
      pcall(require("nvim-treesitter").install, { lang })
    end
  end,
})
vim.api.nvim_create_autocmd("LspAttach", {
  desc = "LSP setup",
  group = group,
  callback = function(ev)
    local buf = ev.buf
    local client_id = ev.data.client_id
    local client = vim.lsp.get_client_by_id(client_id)
    if not client then
      return
    end

    local map = function(lhs, rhs, opts, mode, requires)
      if requires and not client:supports_method(requires) then
        return
      end
      mode = mode or "n"
      opts = type(opts) == "string" and { desc = opts } or opts
      opts.buffer = buf
      vim.keymap.set(mode, lhs, rhs, opts)
    end

    map("grd", vim.lsp.buf.definition, "vim.lsp.buf.definition()")
    map("grD", vim.lsp.buf.declaration, "vim.lsp.buf.declaration()")
    map("grf", vim.lsp.buf.format, "vim.lsp.buf.format()")
    map("gro", vim.diagnostic.open_float, "vim.diagnotic.open_float()")

    if client:supports_method("textDocument/completion") then
      vim.lsp.completion.enable(true, client_id, ev.buf, { autotrigger = true })
    end
    if client:supports_method("textDocument/inlineCompletion") then
      vim.lsp.inline_completion.enable(true, { bufnr = buf })
    end
    if client:supports_method("textDocument/documentHighlight") then
      local hl_group = vim.api.nvim_create_augroup("lsp_document_highlight_" .. buf, { clear = true })
      vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
        buffer = buf,
        group = hl_group,
        callback = vim.lsp.buf.document_highlight,
      })
      vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "BufLeave" }, {
        buffer = buf,
        group = hl_group,
        callback = vim.lsp.buf.clear_references,
      })
      vim.api.nvim_create_autocmd("LspDetach", {
        buffer = buf,
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
      vim.lsp.codelens.enable(true, { bufnr = buf })
    end
    if client:supports_method("textDocument/inlayHint") then
      map("<leader>uh", function()
        vim.lsp.inlay_hint.enable(
          not vim.lsp.inlay_hint.is_enabled({ bufnr = buf })
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

-- LSP ========================================================================

local servers = vim.iter(vim.api.nvim_get_runtime_file("lsp/*.lua", true))
  :map(function(path)
    return vim.fn.fnamemodify(path, ":t:r")
  end)
  :totable()
vim.lsp.enable(servers)

vim.diagnostic.config({
  severity_sort = true,
  update_in_insert = false,
  underline = true,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = " ",
      [vim.diagnostic.severity.WARN] = " ",
      [vim.diagnostic.severity.INFO] = " ",
      [vim.diagnostic.severity.HINT] = " ",
    },
  },
  virtual_text = {
    current_line = false,
  },
  virtual_lines = {
    current_line = true,
  },
})

-- Plugins ====================================================================
vim.pack.add({
  "https://github.com/tpope/vim-sleuth",
  "https://github.com/nvim-treesitter/nvim-treesitter",
  "https://github.com/mason-org/mason.nvim",
  "https://github.com/stevearc/oil.nvim",
  "https://github.com/ibhagwan/fzf-lua",
  "https://github.com/lewis6991/gitsigns.nvim",
})
vim.cmd.packadd("nvim.difftool")

require("mason").setup()
require("oil").setup()

require("gitsigns").setup({
  current_line_blame = true,
  on_attach = function(buf)
    local gs = require("gitsigns")

    local map = function(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = buf, desc = desc })
    end

    -- stylua: ignore start
    local nav = function(key, dir)
      if vim.wo.diff then
        vim.cmd.normal(key, { bang = true })
      else
        gs.nav_hunk(dir)
      end
    end

    map("n", "]c", function() nav("]c", "next") end, "Next Hunk")
    map("n", "[c", function() nav("[c", "prev") end, "Prev Hunk")
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
    map("n", "<leader>hD", function() gs.diffthis("@") end, "Diff Agsint HEAD")
    map("n", "<leader>hQ", function() gs.setqflist("all") end, "Send to Quickfix")

    map("n", "<leader>ub", gs.toggle_current_line_blame, "Toggle Blame Line")

    map({ "o", "x" }, "ih", gs.select_hunk, "Select Hunk")
    -- stylua: ignore end
  end,
})
