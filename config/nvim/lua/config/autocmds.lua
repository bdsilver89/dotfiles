local autocmd = vim.api.nvim_create_autocmd

local function augroup(name)
  return vim.api.nvim_create_augroup("config_" .. name, { clear = true })
end

-- check if file reload is needed
autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  desc = "Check for file reload",
  group = augroup("checktime"),
  callback = function()
    if vim.o.buftype ~= "nofile" then
      vim.cmd("checktime")
    end
  end,
})

-- highlight on yank
autocmd("TextYankPost", {
  desc = "Highlight on yank",
  group = augroup("highlight_yank"),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- resize splits
autocmd("VimResized", {
  desc = "Resize splits on editor resize",
  group = augroup("resize_splits"),
  callback = function()
    local current_tab = vim.fn.tabpagenr()
    vim.cmd("tabdo wincmd = ")
    vim.cmd("tabnext " .. current_tab)
  end,
})

-- auto-create dirs when saving a buffer
autocmd("BufWritePre", {
  desc = "Auto create dirs when saving a buffer",
  group = augroup("auto_create_dir"),
  callback = function()
    if event.match:match("^%w%w+:[\\/][\\/]") then
      return
    end
    local file = vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})
