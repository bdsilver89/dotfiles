vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("highlight_yank", { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("qclose", { clear = true }),
  pattern = {
    "checkhealth",
    "dap-float",
    "dbout",
    "git",
    "gitsigns-blame",
    "grug-far",
    "help",
    "man",
    "neotest-output-panel",
    "neotest-output",
    "neotest-summary",
    "qf",
  },
  callback = function(ev)
    vim.bo[ev.buf].buflisted = false
    vim.schedule(function()
      vim.keymap.set("n", "q", function()
        pcall(vim.api.nvim_buf_delete, ev.buf, { force = true })
      end, { desc = "Quit buffer", silent = true, buffer = ev.buf })
    end)
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("bigfile", { clear = true }),
  pattern = "bigfile",
  callback = function(ev)
    vim.schedule(function()
      vim.bo[ev.buf].syntax = vim.filetype.match({ buf = ev.buf }) or ""
    end)
  end,
})

vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  group = vim.api.nvim_create_augroup("autodir", { clear = true }),
  callback = function(ev)
    if ev.match:match("^%w%w+:[\\/][\\/]") then
      return
    end
    local file = vim.uv.fs_realpath(ev.match) or ev.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})
