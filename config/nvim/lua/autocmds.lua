vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("config_hlyank", { clear = true }),
  callback = function()
    if vim.fn.has("nvim-0.13") == 1 then
      vim.hl.hl_op()
    else
      vim.hl.on_yank()
    end
  end,
})

vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group = vim.api.nvim_create_augroup("config_checktime", { clear = true }),
  callback = function()
    if vim.o.buftype ~= "nofile" then
      vim.cmd("checktime")
    end
  end,
})

vim.api.nvim_create_autocmd("VimResized", {
  group = vim.api.nvim_create_augroup("config_resized", { clear = true }),
  callback = function()
    local current_tab = vim.fn.tabpagenr()
    vim.cmd("tabdo wincmd =")
    vim.cmd("tabnext " .. current_tab)
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("config_close", { clear = true }),
  pattern = {
    "checkhealth",
    "gitsigns-blame",
    "help",
    "lspinfo",
    "neotest-output",
    "neotest-output-panel",
    "neotest-summary",
    "notify",
    "qf",
    "startuptime",
    "nvim-undotree",
  },
  callback = function(ev)
    vim.bo[ev.buf].buflisted = false
    vim.schedule(function()
      vim.keymap.set("n", "q", function()
        vim.cmd("close")
        pcall(vim.api.nvim_buf_delete, ev.buf, { force = true })
      end, {
        buffer = ev.buf,
        silent = true,
        desc = "Close buffer",
      })
    end)
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("config_unlisted", { clear = true }),
  pattern = { "man" },
  callback = function(ev)
    vim.bo[ev.buf].buflisted = false
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("config_wrapspell", { clear = true }),
  pattern = {
    "text",
    "gitcommit",
    "markdown",
  },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("config_jsonconceal", { clear = true }),
  pattern = {
    "json",
    "jsonc",
    "json5",
  },
  callback = function()
    vim.opt_local.conceallevel = 0
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("config_createdir", { clear = true }),
  callback = function(ev)
    if ev.match:match("^%w%w+:[\\/][\\/]") then
      return
    end
    local file = vim.uv.fs_realpath(ev.match) or ev.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})

vim.api.nvim_create_user_command("PackClean", function()
  local inactive = vim
    .iter(vim.pack.get())
    :filter(function(x)
      return not x.active
    end)
    :map(function(x)
      return x.spec.name
    end)
    :totable()
  if #inactive == 0 then
    vim.notify("No inactive plugins to remove")
    return
  end
  vim.pack.del(inactive)
  vim.notify("Removed: " .. table.concat(inactive, ", "))
end, { desc = "Remove plugins not specified" })

vim.api.nvim_create_user_command("PackUpdate", function()
  vim.pack.update()
end, { desc = "Update plugins" })

vim.api.nvim_create_user_command("StartupTime", function()
  local log = vim.fn.tempname()
  vim.system({ "nvim", "--startuptime", log, "-c", "q" }, { text = true }, function()
    vim.schedule(function()
      local lines = vim.fn.readfile(log)
      local last = lines[#lines - 1] or ""
      vim.notify("Startup: " .. (last:match("^(%d+%.%d+)") or "?") .. " ms")
    end)
  end)
end, { desc = "Measure startup time" })
