local function make(opts)
  local args = opts.args
  local makeprg = vim.bo.makeprg ~= "" and vim.bo.makeprg or vim.o.makeprg

  -- Handle $* substitution in makeprg
  local substituted, count = makeprg:gsub("%$%*", args)
  if count == 0 then
    makeprg = makeprg .. " " .. args
  else
    makeprg = substituted
  end
  makeprg = vim.fn.expandcmd(vim.trim(makeprg))

  local state = {}

  local function on_exit(obj)
    vim.schedule(function()
      vim.fn.setqflist({}, "a", { id = state.qf, context = { code = obj.code } })
      vim.api.nvim_exec_autocmds("QuickFixCmdPost", { pattern = "make", modeline = false })

      local now = vim.uv.hrtime()
      local elapsed = (now - state.start) / 1e9
      local message
      if obj.code ~= 0 then
        message = string.format("Command %s exited after %.2f seconds with error code %d", makeprg, elapsed, obj.code)
      else
        message = string.format("Command %s finished successfully after %.2f seconds", makeprg, elapsed)
      end

      if obj.code ~= 0 then
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
          local qfinfo = vim.fn.getqflist({ id = 0, qfbufnr = true })
          state.qf = qfinfo.id
          vim.keymap.set("n", "<C-C>", function()
            local result = state.handle:wait(0)
            if result.signal ~= 0 then
              local title = string.format("%s (Interrupted)", makeprg)
              vim.fn.setqflist({}, "a", { title = title })
            end
          end, { buffer = qfinfo.qfbufnr })
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

local group = vim.api.nvim_create_augroup("make#", { clear = true })

vim.api.nvim_create_autocmd("QuickFixCmdPost", {
  group = group,
  pattern = "make",
  nested = true,
  desc = "Focus the quickfix window on the first error (if any)",
  callback = function()
    local qfinfo = vim.fn.getqflist({ items = true, winid = true, context = true })
    local found = false
    for i, item in ipairs(qfinfo.items) do
      if item.valid == 1 then
        found = true
        vim.api.nvim_win_set_cursor(qfinfo.winid, { i, 0 })
        break
      end
    end
    if qfinfo.context.code == 0 and not found then
      vim.cmd("cclose")
    end
  end,
})

vim.keymap.set("n", "<leader>m", ":<C-U>Make ", { silent = false })
vim.keymap.set("n", "<leader>M", "<Cmd>Make<CR>")
