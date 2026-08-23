local function run_make(opts)
  local args = opts.args
  local makeprg, n = vim.o.makeprg:gsub("%$%*", args)
  if n == 0 then
    makeprg = makeprg .. " " .. args
  end
  makeprg = vim.fn.expandcmd(vim.trim(makeprg))

  local state = {}

  local function on_exit(obj)
    vim.schedule(function()
      vim.fn.setqflist({}, "a", { id = state.qf, context = { code = obj.code } })
      vim.api.nvim_exec_autocmds("QuickFixCmdPost", { pattern = "make", modeline = false })
      if obj.code ~= 0 then
        local now = vim.uv.hrtime()
        local elapsed = (now - state.start) / 1e9
        print(("Command %s exited after %.2f seconds with error code %d"):format(makeprg, elapsed, obj.code))
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
          local qf = vim.fn.getqflist({ id = 0, qfbufnr = true })
          state.qf = qf.id
          vim.keymap.set("n", "<C-C>", function()
            local result = state.handle:wait(0)
            if result.signal ~= 0 then
              local title = ("%s (Interrupted)"):format(makeprg)
              vim.fn.setqflist({}, "a", { title = title })
            end
          end, { buffer = qf.qfbufnr })
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

vim.api.nvim_create_user_command("Make", run_make, { nargs = "*" })

local group = vim.api.nvim_create_augroup("make", { clear = true })

vim.api.nvim_create_autocmd("QuickFixCmdPost", {
  group = group,
  pattern = "make",
  nested = true,
  desc = "Focus the quickfix window on the first error (if any)",
  callback = function()
    local qf = vim.fn.getqflist({ items = true, winid = true, context = true })
    local items, winid, code = qf.items, qf.winid, qf.context.code
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

vim.keymap.set("n", "m?", function()
  print(vim.o.makeprg)
end)
vim.keymap.set("n", "m<Space>", ":<C-U>Make ", { silent = false })
vim.keymap.set("n", "m<CR>", "<Cmd>Make<CR>")
