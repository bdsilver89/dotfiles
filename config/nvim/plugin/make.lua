local focused = true

local function notify(title, msg)
  io.stdout:write(string.format("\027]777;notify;%s;%s\027\\", title, msg))
end

local function make(opts)
  local args = opts.args
  local makeprg
  local s, n = vim.o.makeprg:gsub("%$%*", args)
  if n == 0 then
    makeprg = s .. " " .. args
  else
    makeprg = s
  end
  makeprg = vim.fn.expandcmd(vim.trim(makeprg))
  local state = {}

  local function on_exit(result)
    local code = result.code
    vim.schedule(function()
      vim.fn.setqflist({}, "a", { id = state.qf, context = { code = code } })
      vim.api.nvim_exec_autocmds("QuickFixCmdPost", { pattern = "make", modeline = false })
      local now = vim.uv.hrtime()
      local elapsed = (now - state.start) / 1e9
      local message
      if code ~= 0 then
        message = string.format("Command %s exited after %.2f seconds with error code %d", makeprg, elapsed, code)
      else
        message = string.format("Command %s finished successfully after %.2f seconds", makeprg, elapsed)
      end
      if not focused then
        notify("Neovim", message)
      elseif code ~= 0 then
        print(message)
      end
    end)
  end

  local function on_data(err, data)
    assert(not err, err)
    if data then
      vim.schedule(function()
        local lines = vim.split(data, "\n", { trimempty = true })
        if not state.qf then
          vim.fn.setqflist({}, " ", { title = makeprg, nr = "$" })
          vim.cmd("botright copen|wincmd p")
          local qflist = vim.fn.getqflist({ id = 0, qfbufnr = true })
          local id = qflist.id
          local qfbufnr = qflist.qfbufnr
          state.qf = id
          vim.keymap.set("n", "<C-C>", function()
            local result = state.handle:wait(0)
            if result.signal ~= 0 then
              local title = string.format("%s (Interrupted)", makeprg)
              vim.fn.setqflist({}, "a", { title = title })
            end
          end, { buffer = qfbufnr })
        end
        vim.fn.setqflist({}, "a", { id = state.qf, lines = lines })
        vim.cmd("cbottom")
      end)
    end
  end

  vim.api.nvim_exec_autocmds("QuickFixCmdPre", { pattern = "make", modeline = false })
  state.handle = vim.system(vim.split(makeprg, " "), { stdout = on_data, stderr = on_data }, on_exit)
  state.start = vim.uv.hrtime()
end

vim.api.nvim_create_user_command("Make", make, { nargs = "*" })

vim.api.nvim_create_augroup("make#", { clear = true })
vim.api.nvim_create_autocmd("QuickFixCmdPost", {
  group = "make#",
  pattern = "make",
  nested = true,
  desc = "Focus the quickfix window on the first error (if any)",
  callback = function()
    local qflist = vim.fn.getqflist({ items = true, winid = true, context = true })
    local items = qflist.items
    local winid = qflist.winid
    local context = qflist.context
    local code = context and context.code
    local found = false
    for i, item in ipairs(items) do
      if item.valid == 1 then
        found = true
        vim.api.nvim_win_set_cursor(winid, { i, 0 })
        break
      end
    end
    if code == 0 and not found then
      vim.cmd("cclose")
    end
  end,
})

vim.api.nvim_create_autocmd("FocusGained", {
  group = "make#",
  pattern = "*",
  callback = function()
    focused = true
  end,
})

vim.api.nvim_create_autocmd("FocusLost", {
  group = "make#",
  pattern = "*",
  callback = function()
    focused = false
  end,
})

vim.keymap.set("n", "<leader>m", ":<C-U>Make ", { silent = false })
vim.keymap.set("n", "<leader>M", "<Cmd>Make<CR>")

