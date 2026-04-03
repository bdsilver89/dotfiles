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
  desc = "Close files filetypes with <q>",
  group = group,
  pattern = { "git", "help", "man", "qf" },
  callback = function(ev)
    if ev.match ~= "help" or not vim.bo[ev.buf].modifiable then
      vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = ev.buf, silent = true })
    end
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  desc = "Disable features for big files",
  group = group,
  pattern = "bigfile",
  callback = function(ev)
    vim.schedule(function()
      vim.bo[ev.buf].syntax = vim.filetype.match({ buf = ev.buf }) or ""
    end)
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

