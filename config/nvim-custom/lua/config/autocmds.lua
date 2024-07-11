vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("config_highlight_yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
  desc = "highlight on yank",
})

vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group = vim.api.nvim_create_augroup("config_checktime", { clear = true }),
  callback = function()
    if vim.o.buftype ~= "nofile" then
      vim.cmd("checktime")
    end
  end,
  desc = "check for file reload",
})

vim.api.nvim_create_autocmd("VimResized", {
  group = vim.api.nvim_create_augroup("config_resize_splits", { clear = true }),
  callback = function()
    local current_tab = vim.fn.tabpagenr()
    vim.cmd("tabdo wincmd = ")
    vim.cmd("tabnext " .. current_tab)
  end,
  desc = "resize splits if editor resizes",
})

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("config_close_with_q", { clear = true }),
  pattern = {
    "checkhealth",
    "fugitive",
    "fugitiveblame",
    "help",
    "lspinfo",
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
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
  end,
  desc = "close filetypes with q",
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
  desc = "conceallevel for json"
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
