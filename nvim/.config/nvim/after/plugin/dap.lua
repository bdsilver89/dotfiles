local dap = require('dap')
local dapui = require('dapui')
local daptext = require('nvim-dap-virtual-text')

daptext.setup({})

dapui.setup({
  layouts = {
    {
      elements = {
        'repl',
        'console',
      },
      size = 0.25,
      position = 'bottom',
    },
    {
      elements = {
        { id = 'scopes', size = 0.25 },
        'watches',
        'breakpoints',
        'stacks'
      },
      size = 40,
      position = 'left',
    },
  },
  controls = {
    enabled = true,
    element = 'repl',
    icons = {
      pause = '',

      play = '',
      step_into = '',
      step_over = '',
      step_out = '',
      step_back = '',
      run_last = '↻',
      terminate = '□',
    },
  },
  windows = {
    indent = 1
  },
  floating = {
    max_height = nil,
    max_width = nil,
    border = 'single',
    mappings = {
      close = { 'q', '<Esc>' }
    }
  }
})

dap.listeners.after.event_initialized['dapui_config'] = function()
  dapui.open()
end

dap.listeners.after.event_terminated['dapui_config'] = function()
  dapui.close()
end

dap.listeners.after.event_exited['dapui_config'] = function()
  dapui.close()
end

vim.keymap.set('n', '<F12>', function() dapui.toggle() end, { desc = 'DAP: Toggle UI' })
vim.keymap.set('n', '<F1>', function() dapui.continue() end, { desc = 'DAP: Continue' })
vim.keymap.set('n', '<F2>', function() dapui.step_over() end, { desc = 'DAP: Step over' })
vim.keymap.set('n', '<F3>', function() dapui.step_out() end, { desc = 'DAP: Step out' })
vim.keymap.set('n', '<F4>', function() dapui.step_into() end, { desc = 'DAP: Step into' })

vim.keymap.set('n', '<leader>b', function() dap.toggle_breakpoint() end, { desc = 'DAP: Toggle breakpoint' })
vim.keymap.set('n', '<leader>B', function()
  dap.set_breakpoint(vim.fn.input('Breakpoint condition: '))
end, { desc = 'DAP: Breakpoint' })
vim.keymap.set('n', '<leader>rc', function() dap.run_to_cursor() end, { desc = 'DAP: Run to cursor' })

-- vim.keymap.set('n', '<leader><leader>', function() dapui.close() end)

dap.adapters.lldb = {
  type = 'executable',
  command = '/usr/bin/lldb-vscode',
  name = 'lldb',
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
    end,
  }
}

dap.configurations.c = dap.configurations.cpp
dap.configurations.rust = dap.configurations.cpp
