local autocmd = vim.api.nvim_create_autocmd

local function augroup(name)
  return vim.api.nvim_create_augroup("config_" .. name, { clear = true })
end

autocmd("TextYankPost", {
  desc = "Highlight yanked text",
  group = augroup("highlightyank"),
  callback = function()
    vim.highlight.on_yank()
  end,
})

autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  desc = "Check for file reload",
  group = augroup("checktime"),
  callback = function()
    if vim.o.buftype ~= "nofile" then
      vim.cmd.checktime()
    end
  end,
})

autocmd("VimResized", {
  desc = "Resize splits when window resizes",
  group = augroup("resize_splits"),
  callback = function()
    local current_tab = vim.fn.tabpagenr()
    vim.cmd("tabdo wincmd =")
    vim.cmd("tabnext " .. current_tab)
  end,
})

autocmd("BufReadPost", {
  desc = "Go to last loc when opening a buffer",
  group = augroup("lastloc"),
  callback = function(event)
    local exclude = { "gitcommit" }
    local buf = event.buf
    if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].config_last_loc then
      return
    end
    vim.b[buf].config_last_loc = true
    local mark = vim.api.nvim_buf_get_mark(buf, '"')
    local lcount = vim.api.nvim_buf_line_count(buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

autocmd("Filetype", {
  desc = "Close with <q>",
  group = augroup("quick_close"),
  pattern = {
    "checkhealth",
    "dbout",
    "fugitive",
    "fugitiveblame",
    "gitsigns-blame",
    "git",
    "grug-far",
    "help",
    "lspinfo",
    "neotest-summary",
    "neotest-output-panel",
    "notify",
    "qf",
    "query",
    "spectre_panel",
    "startuptime",
    "toggleterm",
    "undotree",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true, desc = "Quit buffer" })
  end,
})

autocmd("FileType", {
  desc = "wrap and check for spelling",
  group = augroup("wrap_spell"),
  pattern = {
    "*.txt",
    "gitcommit",
    "markdown",
  },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})

autocmd("FileType", {
  desc = "conceallevel for json",
  group = augroup("json_conceal"),
  pattern = { "json", "jsonc", "json5" },
  callback = function()
    vim.opt_local.conceallevel = 0
  end,
})

-- autocmd("FileType", {
--   desc = "foldcolumn",
--   group = augroup("foldcolumn"),
--   pattern = {
--     "Neogit*",
--   },
--   callback = function()
--     vim.opt_local.foldcolumn = "0"
--   end,
-- })

autocmd("BufWritePre", {
  desc = "Auto create dir before saving buffer",
  group = augroup("auto_create_dir"),
  callback = function(event)
    if event.match:match("^%w%w+:[\\/][\\/]") then
      return
    end
    local file = vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})

-- autocmd("QuickFixCmdPost", {
--   desc = "Auto open Trouble quickfix",
--   -- group = augroup("auto_trouble_qflist"),
--   callback = function()
--     vim.cmd([[Trouble qflist open]])
--   end,
-- })

vim.filetype.add({
  pattern = {
    [".*"] = {
      function(path, buf)
        return vim.bo[buf]
            and vim.bo[buf].filetype ~= "bigfile"
            and path
            and vim.fn.getfsize(path) > vim.g.bigfile_size
            and "bigfile"
          or nil
      end,
    },
  },
})

autocmd("FileType", {
  desc = "Big file",
  pattern = "bigfile",
  callback = function(ev)
    vim.b.minianimate_disable = true
    vim.schedule(function()
      vim.bo[ev.buf].syntax = vim.filetype.match({ buf = ev.buf }) or ""
    end)
  end,
})

autocmd({ "TextChanged", "TextChangedI", "TextChangedP", "VimResized", "LspAttach", "WinScrolled", "BufEnter" }, {
  desc = "Colorify file",
  group = augroup("colorify"),
  callback = function(event)
    if vim.bo[event.buf].bl then
      require("config.ui.colorify").attach(event.buf, event.event)
    end
  end,
})
