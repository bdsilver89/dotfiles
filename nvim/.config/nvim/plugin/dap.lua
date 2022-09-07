local status, dap = pcall(require, 'dap')
if (not status) then return end

local dapui = require('dapui')
local daptext = require('nvim-dap-virtual-text')

daptext.setup({})
dapui.setup({
  layouts = {
    {
      elements = {
        'console',
      },
      size = 7,
      position = 'bottom',
    },
    {
      elements = {
        { id = 'scopes', size = 0.25 },
        'watches',
      },
      size = 40,
      position = 'left',
    }
  },
})

dap.listeners.after.event_initialized["dapui_config"] = function()
  dapui.open(1)
end

dap.listeners.after.event_terminated["dapui_config"] = function()
  dapui.close()
end

dap.listeners.after.event_exited["dapui_config"] = function()
  dapui.close()
end

-- c/c++/rust
dap.adapters.lldb = {
  type = 'executable',
  command = '/usr/bind/lldb-vscode',
  name = 'lldb'
}
dap.configurations.cpp = {
 {
    name = 'Launch',
    type = 'lldb',
    request = 'launch',
    program = function()
      return vim.fn.input('Path to executable: ', vim.loop.cwd() .. '/', 'file')
    end,
    cwd = '${workspaceFolder}',
    stopOnEntry = true,
    args = function()
      return vim.fn.input('Args: ')
    end
  }
  -- {
  --   name = 'Attach',
  --   type = 'lldb',
  --   request = 'attach',
  --   Id = require('dap.utils').pick_process()
  -- }
}
dap.configurations.c = dap.configurations.cpp
dap.configurations.rust = dap.configurations.cpp

-- go
-- dap.adapters.go = function(callback, cfg)
--   local stdout = vim.loop.new_pipe(false)
--   local handle
--   local pid_or_err
--   local host = cfg.host or '127.0.0.1'
--   local port = cfg.port or '38697'
--   local addr = string.format('%s:%s', host, port)
--   local opts = {
--     stdio = { nil, stdout },
--     args = { 'dap', '-l', addr },
--     detached = true
--   }
--
--   handle, pid_or_err = vim.loop.spawn('dlv', opts, function(code)
--     stdout:close()
--     handle:close()
--     if code ~= 0 then
--       print('dlv exited with code', code)
--     end
--   end)
--   assert(handle, "Error running dlv:" .. tostring(pid_or_err))
--   stdout:read_start(function(err, chunk)
--     assert(not err, err)
--     if chunk then
--       vim.schedule(function()
--         require('dap.repl').append(chunk)
--       end)
--     end
--   end)
--   vim.defer_fn(function()
--     callback({type = 'server', host = '127.0.0.1', port = port })
--   end,
--   100)
-- end
--
-- dap.configurations.go = {
--   {
--     type = 'go',
--     name = 'Debug',
--     request = 'launch',
--     program = '${file}'
--   },
--   {
--     type = 'go',
--     name = 'Debug Package',
--     request = 'launch',
--     program = '${fileDirname}'
--   },
--   {
--     type = 'go',
--     name = 'Attach',
--     mode = 'local',
--     request = 'attach',
--     Id = require('dap.utils').pick_process(),
--   },
--   {
--     type = 'go',
--     name = 'Debug test',
--     request = 'launch',
--     mode = 'test',
--     program = '${file}'
--   },
--   {
--     type = 'go',
--     name = 'Debug test (go.mod)',
--     request = 'launch',
--     mode = 'test',
--     program = './${relativeFileDirname}'
--   },
-- }

vim.keymap.set('n', '<F12>', function() dapui.toggle() end, { noremap = true })

vim.keymap.set('n', '<leader><leader>', function() dap.close() end, { noremap = true })
vim.keymap.set('n', '<F1>', function() dap.continue() end, { noremap = true })
vim.keymap.set('n', '<F2>', function() dap.step_over() end, { noremap = true })
vim.keymap.set('n', '<F3>', function() dap.step_out() end, { noremap = true })
vim.keymap.set('n', '<F4>', function() dap.step_into() end, { noremap = true })

vim.keymap.set('n', '<leader>b', function() dap.toggle_breakpoint() end, { noremap = true })
vim.keymap.set('n', '<leader>B', function() dap.set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, { noremap = true })
vim.keymap.set('n', '<leader>rc', function() dap.run_to_cursor() end, { noremap = true })
