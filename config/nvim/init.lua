-- Options ====================================================================

vim.g.mapleader = " "
vim.g.maplocalleader = " "

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
vim.opt.smartcase = true
vim.opt.smoothscroll = true
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.tabstop = 2
vim.opt.termguicolors = true
vim.opt.undofile = true
vim.opt.undolevels = 10000
vim.opt.wildmode = "longest:full,full"
vim.opt.wrap = false

vim.schedule(function()
  vim.opt.clipboard = vim.env.SSH_TTY and "" or "unnamedplus"
end)

vim.schedule(function()
  vim.cmd.colorscheme("catppuccin")
end)

-- %<%f %h%w%m%r %{% v:lua.require('vim._core.util').term_exitcode() %}%=%{% luaeval('(package.loaded[''vim.ui''] and vim.api.nvim_get_current_win() == tonumber(vim.g.actual_curwin or -1) and vim.ui.progress_status()) or '''' ')%}%{% &showcmdloc == 'statusline' ? '%-10.S ' : '' %}%{% exists('b:keymap_name') ? '<'..b:keymap_name..'> ' : '' %}%{% &busy > 0 ? '◐ ' : '' %}%{% luaeval('(package.loaded[''vim.diagnostic''] and next(vim.diagnostic.count()) and vim.diagnostic.status() .. '' '') or '''' ') %}%{% &ruler ? ( &rulerformat == '' ? '%-14.(%l,%c%V%) %P' : &rulerformat ) : '' %}

-- Plugin =====================================================================

vim.cmd.packadd("nvim.difftool")

require("vim._core.ui2").enable({
  enable = true,
})

vim.pack.add({
  "https://github.com/nvim-treesitter/nvim-treesitter",
  "https://github.com/nvim-treesitter/nvim-treesitter-textobjects",
  "https://github.com/mason-org/mason.nvim",
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

require("fzf-lua").setup({
  "default-title",
  defaults = { formatter = "path.filename_first" },
})

-- LSP ========================================================================

vim.lsp.enable({ "clangd", "basedpyright", "jdtls", "lua_ls", "rust_analyzer" })
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

vim.keymap.set("n", "-", "<cmd>Oil<cr>")
vim.keymap.set("n", "<leader>ut", function()
  vim.cmd.packadd("nvim.undotree")
  require("undotree").open()
end)

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

vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  desc = "Check for file reload",
  group = group,
  callback = function()
    if vim.o.buftype ~= "nofile" then
      vim.cmd("checktime")
    end
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
    if lang then
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
    -- if client:supports_method("textDocument/documentColor") then
    --   vim.lsp.completion.enable(true, { bufnr = buf }, { style = "virtual" })
    -- end
  end,
})

-- User Commands ==============================================================

vim.api.nvim_create_user_command("Make", function(opts)
  local args = opts.args or ""
  local makeprg, n = vim.o.makeprg:gsub("%$%*", args)
  if n == 0 then
    makeprg = makeprg .. " " .. args
  end

  local efm = vim.o.errorformat
  local state = {}

  local function on_exit(result)
    vim.schedule(function()
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
          local result = state.handle:wait(0)
          if result.signal ~= 0 then
            vim.fn.setqflist({}, "a", { title = ("%s (Interrupted)"):format(makeprg) })
          end
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
