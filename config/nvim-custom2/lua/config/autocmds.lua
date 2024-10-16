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

autocmd({ "TextChanged", "TextChangedI", "TextChangedP", "VimResized", "LspAttach", "WinScrolled", "BufEnter" }, {
  desc = "Colorify file",
  group = augroup("colorify"),
  callback = function(event)
    if vim.bo[event.buf].bl then
      require("config.ui.colorify").attach(event.buf, event.event)
    end
  end,
})
