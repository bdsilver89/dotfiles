vim.api.nvim_create_user_command("Make", function(opts)
  local args = opts.args or ""
  local mp = vim.bo.makeprg
  if mp == "" then
    mp = vim.go.makeprg
  end
  local makeprg, n = mp:gsub("%$%*", args)
  if n == 0 and args ~= "" then
    makeprg = makeprg .. " " .. args
  end

  local efm = vim.bo.errorformat
  if efm == "" then
    efm = vim.go.errorformat
  end
  local state = {}

  local function on_exit(result)
    vim.schedule(function()
      if state.interrupted then
        vim.fn.setqflist({}, "a", { id = state.qf, title = ("%s (Interrupted)"):format(makeprg) })
      end
      vim.fn.setqflist({}, "a", { id = state.qf, context = { code = result.code } })
      local now = vim.uv.hrtime()
      local elapsed = (now - state.start) / 1e9
      local msg = ("Make: %s (%.2fs)"):format(makeprg, elapsed)
      if state.interrupted then
        vim.api.nvim_echo({ { msg } }, false, { kind = "progress", source = "make", id = "make", status = "cancel" })
      elseif result.code ~= 0 then
        vim.api.nvim_echo(
          { { msg .. " [exit " .. result.code .. "]" } },
          false,
          { kind = "progress", source = "make", id = "make", status = "failed" }
        )
      else
        vim.api.nvim_echo({ { msg } }, false, { kind = "progress", source = "make", id = "make", status = "success" })
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
          state.interrupted = true
          state.handle:kill("sigint")
        end, { buffer = info.qfbufnr })
      end
      vim.fn.setqflist({}, "a", { id = state.qf, lines = lines, efm = efm })
      vim.cmd("cbottom")
    end)
  end

  vim.api.nvim_echo(
    { { "Make: " .. makeprg } },
    false,
    { kind = "progress", source = "make", id = "make", status = "running" }
  )
  state.handle = vim.system({ "sh", "-c", makeprg }, { stdout = on_data, stderr = on_data }, on_exit)
  state.start = vim.uv.hrtime()
end, { nargs = "*" })
