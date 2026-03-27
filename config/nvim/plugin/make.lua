vim.api.nvim_create_user_command("Make", function(opts)
  local args = opts.args or ""
  local makeprg, n = vim.o.makeprg:gsub("%$%*", args)
  if n == 0 then
    makeprg = makeprg .. " " .. args
  end

  local efm = vim.o.errorformat
  local state = {}

  local function on_exit(result)
    vim.schedule(function()
      vim.fn.setqflist({}, "a", { id = state.qf, context = { code = result.code } })
      vim.api.nvim_exec_autocmds("QuickFixCmdPost", { pattern = "make", modeline = false })

      local now = vim.uv.hrtime()
      local elapsed = (now - state.start) / 1e9
      if result.code ~= 0 then
        vim.print(("Command %s exited after %.2f seconds with error code %d"):format(makeprg, elapsed, result.code))
      end
    end)
  end

  local function on_data(err, data)
    assert(not err, err)
    if not data then
      return
    end
    vim.schedule(function()
      local lines = vim.split(data, "\n", { trimempty = true })
      if not state.qf then
        vim.fn.setqflist({}, " ", { title = makeprg, nr = "$" })
        vim.cmd("botright copen | wincmd p")
        local info = vim.fn.getqflist({ id = 0, qfbufnr = true })
        state.qf = info.id
        vim.keymap.set("n", "<c-c>", function()
          local result = state.handle:wait(0)
          if result.signal ~= 0 then
            vim.fn.setqflist({}, "a", { title = ("%s (Interrupted)"):format(makeprg) })
          end
        end, { buffer = info.qfbufnr })
      end
      vim.fn.setqflist({}, "a", { id = state.qf, lines = lines, efm = efm })
      vim.cmd("cbottom")
    end)
  end

  vim.api.nvim_exec_autocmds("QuickFixCmdPre", { pattern = "make", modeline = false })
  state.handle = vim.system(vim.split(makeprg, "%s+", { trimempty = true }), { stdout = on_data, stderr = on_data }, on_exit)
  state.start = vim.uv.hrtime()
end, { nargs = "*" })
