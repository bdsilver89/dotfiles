local autocmd = vim.api.nvim_create_autocmd
local augroup = function(name)
  return vim.api.nvim_create_augroup("bdsilver89/" .. name, { clear = true })
end

autocmd("TextYankPost", {
  desc = "Highlight on yank",
  group = augroup("yank_highlight"),
  callback = function()
    vim.hl.on_yank()
  end,
})

autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  desc = "Check for file reload",
  group = augroup("checktime"),
  callback = function()
    if vim.o.buftype ~= "nofile" then
      vim.cmd("checktime")
    end
  end,
})

autocmd("VimResized", {
  desc = "Resize splits",
  group = augroup("resize_splits"),
  callback = function()
    local current_tab = vim.fn.tabpagenr()
    vim.cmd("tabdo wincmd=")
    vim.cmd("tabnext " .. current_tab)
  end,
})

autocmd("TermOpen", {
  desc = "Terminal settings",
  group = augroup("terminal_settings"),
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
  end,
})

autocmd("FileType", {
  desc = "Close with <q>",
  group = augroup("close_with_q"),
  pattern = {
    "Avante",
    "codecompanion",
    "checkhealth",
    "gitsigns-blame",
    "grug-far",
    "help",
    "man",
    "neotest-output",
    "neotest-output-panel",
    "neotest-summary",
    "qf",
    "query",
  },
  callback = function(args)
    vim.bo[args.buf].buflisted = false
    vim.keymap.set("n", "q", function()
      vim.cmd("close")
      pcall(vim.api.nvim_buf_delete, args.buf, { force = true })
    end, { buffer = args.buf, silent = true, desc = "Quit Buffer" })
  end,
})

autocmd("FileType", {
  desc = "Wrap and spellcheck filetypes",
  group = augroup("wrap_spell"),
  pattern = { "text", "plaintex", "typst", "gitcommit", "markdown" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})

-- Fix conceallevel for json files
autocmd({ "FileType" }, {
  group = augroup("json_conceal"),
  pattern = { "json", "jsonc", "json5" },
  callback = function()
    vim.opt_local.conceallevel = 0
  end,
})

autocmd("BufWritePre", {
  desc = "Auto create dirs when saving file",
  group = augroup("auto_create_dirs"),
  callback = function(event)
    if event.match:match("^%w%w+:[\\/][\\/]") then
      return
    end
    local file = vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})

-- autocmd("QuickFixCmdPost", {
--   callback = function()
--     vim.cmd([[Trouble qflist open]])
--   end,
-- })
