-- Options ====================================================================

vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.autoread = true
vim.opt.breakindent = true
vim.opt.completeopt = { "menuone", "noselect", "popup", "fuzzy" }
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
vim.opt.linebreak = true
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
vim.opt.number = true
vim.opt.pumheight = 10
vim.opt.relativenumber = true
vim.opt.scrolloff = 8
vim.opt.shiftwidth = 2
vim.opt.shortmess:append("c")
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
vim.opt.wildmode = "longest:full,full"
vim.opt.wrap = false

vim.schedule(function()
  vim.opt.clipboard = vim.env.SSH_TTY and "" or "unnamedplus"
  vim.cmd.colorscheme("catppuccin")
end)

-- stylua: ignore start
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
-- stylua: ignore end

-- Plugin =====================================================================

vim.cmd.packadd("nvim.difftool")

require("vim._core.ui2").enable({
  enable = true,
})

vim.pack.add({
  "https://github.com/nvim-treesitter/nvim-treesitter",
  "https://github.com/nvim-treesitter/nvim-treesitter-textobjects",
  "https://github.com/mason-org/mason.nvim",
  "https://github.com/tpope/vim-sleuth",
  "https://github.com/tpope/vim-fugitive",
  "https://github.com/lewis6991/gitsigns.nvim",
  "https://github.com/stevearc/oil.nvim",
  "https://github.com/ibhagwan/fzf-lua",
})

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
require("oil").setup()
require("gitsigns").setup()
require("fzf-lua").setup()

-- Snippets ===================================================================
do
  local snip_dir = vim.fn.stdpath("config") .. "/snippets"
  local cache = {}

  local function get_snippets(ft)
    if not cache[ft] then
      local f = io.open(snip_dir .. "/" .. ft .. ".json", "r")
      if not f then cache[ft] = {} return cache[ft] end
      local snips = {}
      for _, s in pairs(vim.json.decode(f:read("*a"))) do
        local body = type(s.body) == "table" and table.concat(s.body, "\n") or s.body
        snips[type(s.prefix) == "table" and s.prefix[1] or s.prefix] = body
      end
      f:close()
      cache[ft] = snips
    end
    return cache[ft]
  end

  vim.keymap.set({ "i", "s" }, "<c-s>", function()
    local col = vim.fn.col(".") - 1
    local word = vim.fn.getline("."):sub(1, col):match("[%w_-]+$")
    local body = word and get_snippets(vim.bo.filetype)[word]
    if not body then return end
    local line = vim.api.nvim_get_current_line()
    vim.api.nvim_set_current_line(line:sub(1, col - #word) .. line:sub(col + 1))
    vim.api.nvim_win_set_cursor(0, { vim.fn.line("."), col - #word })
    vim.snippet.expand(body)
  end, { desc = "Expand snippet" })
end

-- LSP ========================================================================

vim.lsp.enable({ "basedpyright", "clangd", "copilot", "jdtls", "lua_ls", "rust_analyzer" })

vim.diagnostic.config({
  update_in_insert = false,
  severity_sort = true,
  virtual_text = true,
  virtual_lines = false,
})

-- Keymaps ====================================================================

-- stylua: ignore start
vim.keymap.set({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
vim.keymap.set({ "n", "x" }, "<down>", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
vim.keymap.set({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })
vim.keymap.set({ "n", "x" }, "<up>", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })
-- stylua: ignore end

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

vim.keymap.set("n", "-", "<cmd>Oil<cr>", { desc = "Oil" })

vim.keymap.set({ "i", "s" }, "<tab>", function()
  if vim.snippet.active({ direction = 1 }) then
    return "<cmd>lua vim.snippet.jump(1)<cr>"
  elseif not vim.lsp.inline_completion.get() then
    return "<tab>"
  end
end, { desc = "Next Snippet", expr = true, silent = true })

vim.keymap.set({ "i", "s" }, "<s-tab>", function()
  if vim.snippet.active({ direction = -1 }) then
    return "<cmd>lua vim.snippet.jump(-1)<cr>"
  else
    return "<s-tab>"
  end
end, { desc = "Prev Snippet", expr = true, silent = true })

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

vim.keymap.set("n", "<esc>", "<cmd>nohlsearch<cr>")
vim.keymap.set("t", "<esc><esc>", "<c-\\><c-n>")

vim.keymap.set("n", "<leader>xl", function()
  if vim.fn.getloclist(0, { winid = 0 }).winid ~= 0 then vim.cmd.lclose() else vim.cmd.lopen() end
end, { desc = "Location List" })
vim.keymap.set("n", "<leader>xq", function()
  if vim.fn.getqflist({ winid = 0 }).winid ~= 0 then vim.cmd.cclose() else vim.cmd.copen() end
end, { desc = "Quickfix List" })

-- textobjects
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

-- stylua: ignore start
vim.keymap.set("n", "<leader><leader>", "<cmd>FzfLua files<cr>", { desc = "Files" })
vim.keymap.set("n", "<leader>,", "<cmd>FzfLua buffers<cr>", { desc = "Buffers" })
vim.keymap.set("n", "<leader>/", "<cmd>FzfLua live_grep<cr>", { desc = "Grep" })
-- stylua: ignore end

-- tmux
local function navigate(vdir, tdir)
  local win = vim.api.nvim_get_current_win()
  vim.cmd.wincmd(vdir)
  if (vim.env.TMUX ~= nil) and vim.api.nvim_get_current_win() == win then
    vim.system({ "tmux", "select-pane", "-" .. tdir })
  end
end
vim.keymap.set({ "n", "t" }, "<c-h>", function() navigate("h", "L") end)
vim.keymap.set({ "n", "t" }, "<c-j>", function() navigate("j", "D") end)
vim.keymap.set({ "n", "t" }, "<c-k>", function() navigate("k", "U") end)
vim.keymap.set({ "n", "t" }, "<c-l>", function() navigate("l", "R") end)

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
  desc = "Enable wrap and spell for text files",
  group = group,
  pattern = { "markdown", "text", "gitcommit" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
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

    -- stylua: ignore start
    vim.keymap.set("n", "grd", vim.lsp.buf.definition, { desc = "vim.lsp.buf.definition()", buffer = ev.buf })
    vim.keymap.set("n", "grD", vim.lsp.buf.declaration, { desc = "vim.lsp.buf.declaration()", buffer = ev.buf })
    vim.keymap.set("n", "grf", vim.lsp.buf.format, { desc = "vim.lsp.buf.format()", buffer = ev.buf })
    -- stylua: ignore end

    if client:supports_method("textDocument/completion") then
      vim.lsp.completion.enable(true, client_id, ev.buf, { autotrigger = true })
    end
    if client:supports_method("textDocument/inlineCompletion") then
      vim.lsp.inline_completion.enable(true, { bufnr = buf })
    end
    if client:supports_method("textDocument/documentColor") then
      vim.lsp.document_color.enable(true, { bufnr = buf })
    end
    if client:supports_method("textDocument/documentHighlight") then
      local hl_group = vim.api.nvim_create_augroup("lsp_document_highlight_" .. buf, { clear = true })
      vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
        buffer = buf,
        group = hl_group,
        callback = vim.lsp.buf.document_highlight,
      })
      vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
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
      vim.keymap.set("n", "<leader>uh", function()
        vim.lsp.inlay_hint.enable(
          not vim.lsp.inlay_hint.is_enabled({ bufnr = buf })
        )
      end, { desc = "Toggle Inlay Hints", buffer = buf })
    end
  end,
})

vim.api.nvim_create_autocmd("LspProgress", {
  desc = "Redraw statusline on LSP progress",
  callback = function()
    vim.cmd.redrawstatus()
  end,
})

-- User Commands ==============================================================

vim.api.nvim_create_user_command("Make", function(opts)
  local args = opts.args or ""
  local makeprg, n = vim.o.makeprg:gsub("%$%*", args)
  if n == 0 and args ~= "" then
    makeprg = makeprg .. " " .. args
  end

  local efm = vim.o.errorformat
  local state = {}

  local function on_exit(result)
    vim.schedule(function()
      if state.interrupted then
        vim.fn.setqflist({}, "a", { id = state.qf, title = ("%s (Interrupted)"):format(makeprg) })
      end
      vim.fn.setqflist({}, "a", { id = state.qf, context = { code = result.code } })
      vim.api.nvim_exec_autocmds("QuickFixCmdPost", { pattern = "make", modeline = false })
      local now = vim.uv.hrtime()
      local elapsed = (now - state.start) / 1e9
      if result.code ~= 0 then
        vim.print(("Command %s exited after %.2f seconds with error code %d"):format(makeprg, elapsed, result.code))
      end
    end)
  end

  local function on_data(err, data)
    assert(not err, err)
    if not data then
      return
    end
    vim.schedule(function()
      local lines = vim.split(data, "\n", { trimempty = true })
      if not state.qf then
        vim.fn.setqflist({}, " ", { title = makeprg, nr = "$" })
        vim.cmd("botright copen | wincmd p")
        local info = vim.fn.getqflist({ id = 0, qfbufnr = true })
        state.qf = info.id
        vim.keymap.set("n", "<c-c>", function()
          state.interrupted = true
          state.handle:kill("sigint")
        end, { buffer = info.qfbufnr })
      end
      vim.fn.setqflist({}, "a", { id = state.qf, lines = lines, efm = efm })
      vim.cmd("cbottom")
    end)
  end

  vim.api.nvim_exec_autocmds("QuickFixCmdPre", { pattern = "make", modeline = false })
  state.handle = vim.system(vim.split(makeprg, "%s+", { trimempty = true }), { stdout = on_data, stderr = on_data }, on_exit)
  state.start = vim.uv.hrtime()
end, { nargs = "*" })
