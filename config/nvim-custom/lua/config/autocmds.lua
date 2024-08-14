vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight yanked text",
  group = vim.api.nvim_create_augroup("config_highlightyank", { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  desc = "Check for file reload",
  group = vim.api.nvim_create_augroup("config_checktime", { clear = true }),
  callback = function()
    if vim.o.buftype ~= "nofile" then
      vim.cmd.checktime()
    end
  end,
})

vim.api.nvim_create_autocmd("VimResized", {
  desc = "Resize splits when window resizes",
  group = vim.api.nvim_create_augroup("config_resize_splits", { clear = true }),
  callback = function()
    local current_tab = vim.fn.tabpagenr()
    vim.cmd("tabdo wincmd =")
    vim.cmd("tabnext " .. current_tab)
  end,
})

vim.api.nvim_create_autocmd("Filetype", {
  desc = "Close with <q>",
  group = vim.api.nvim_create_augroup("config_quick_close", { clear = true }),
  pattern = {
    "checkhealth",
    "dbout",
    "fugitive",
    "fugitiveblame",
    "gitsigns.blame",
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
    "und,otree",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true, desc = "Quit buffer" })
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("config_wrap_spell", { clear = true }),
  pattern = {
    "*.txt",
    "gitcommit",
    "markdown",
  },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
  desc = "wrap and check for spelling",
})

vim.api.nvim_create_autocmd({ "FileType" }, {
  group = vim.api.nvim_create_augroup("config_json_conceal", { clear = true }),
  pattern = { "json", "jsonc", "json5" },
  callback = function()
    vim.opt_local.conceallevel = 0
  end,
  desc = "conceallevel for json",
})

vim.api.nvim_create_autocmd("BufWritePre", {
  group = vim.api.nvim_create_augroup("config_auto_create_dir", { clear = true }),
  callback = function(event)
    if event.match:match("^%w%w+:[\\/][\\/]") then
      return
    end
    local file = vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
  desc = "Auto create dir before saving buffer",
})

vim.api.nvim_create_autocmd("QuickFixCmdPost", {
  -- group = vim.api.nvim_create_augroup("config_auto_trouble_qflist", { clear = true }),
  callback = function()
    vim.cmd([[Trouble qflist open]])
  end,
  desc = "Auto open Trouble quickfix",
})
