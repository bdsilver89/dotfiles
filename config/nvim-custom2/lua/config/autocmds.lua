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

autocmd("Filetype", {
  desc = "Close with <q>",
  group = augroup("quick_close"),
  pattern = {
    "aerial",
    "aerial-nav",
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
    vim.schedule(function()
      vim.keymap.set("n", "q", function()
        vim.cmd("close")
        pcall(vim.api.nvim_buf_delete, event.buf, { force = true })
      end, {
        buffer = event.buf,
        silent = true,
        desc = "Quit buffer",
      })
    end)
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
