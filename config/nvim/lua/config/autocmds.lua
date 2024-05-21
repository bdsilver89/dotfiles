vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight on yank",
  group = vim.api.nvim_create_augroup("config_highlight_yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  desc = "Check for file reload",
  group = vim.api.nvim_create_augroup("config_checktime", { clear = true }),
  callback = function()
    if vim.o.buftype ~= "nofile" then
      vim.cmd("checktime")
    end
  end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
  desc = "Automatically create parent directories when saving a file",
  group = vim.api.nvim_create_augroup("config_create_dir", { clear = true }),
  callback = function(event)
    if event.match:match("^%w%w+:[\\/][\\/]") then
      return
    end
    local file = vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})

vim.api.nvim_create_autocmd("BufRead", {
  desc = "Large file detection and feature disable",
  group = vim.api.nvim_create_augroup("config_largefile_detect", { clear = true }),
  callback = function(event)
    local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(event.buf))
    if
      (ok and stats and stats.size > vim.g.large_buf.size)
      or vim.api.nvim_buf_line_count(event.buf) > vim.g.large_buf.lines
    then
      vim.g[event.buf].large_buf = true
      vim.opt_local.wrap = true
      vim.opt_local.list = false
      -- TODO: plugin disable
    end
  end,
})
