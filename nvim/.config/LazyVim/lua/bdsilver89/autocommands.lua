local filetype_settings = vim.api.nvim_create_augroup('FileTypeSettings', { clear = true })

if not vim.g.vscode then
  vim.api.nvim_create_autocmd('FileType', {
    group = filetype_settings,
    pattern = 'lua',
    callback = function()
      vim.opt_local.suffixesadd:prepend '.lua'
      vim.opt_local.suffixesadd:prepend 'init.lua'
      vim.opt_local.path:prepend(vim.fn.stdpath 'config' .. '/lua')
    end,
  })

  local relative_number_toggle = vim.api.nvim_create_augroup('RelativeNumberToggle', { clear = true })

  vim.api.nvim_set_keymap('', ':', '<cmd>set nornu<cr>:', { noremap = true, desc = 'Enter command-line mode' })

  vim.api.nvim_create_autocmd({ 'BufLeave', 'FocusLost', 'InsertEnter', 'WinLeave' }, {
    group = relative_number_toggle,
    pattern = '*',
    callback = function()
      if vim.o.number then
        vim.o.relativenumber = false
        vim.cmd.redraw()
      end
    end,
  })

  vim.api.nvim_create_autocmd({ 'BufEnter', 'CmdLineLeave', 'FocusGained', 'InsertLeave', 'WinEnter' }, {
    group = relative_number_toggle,
    pattern = '*',
    callback = function()
      if vim.o.number then
        vim.o.relativenumber = true
      end
    end,
  })

  -- remove line numbers from terminals
  vim.api.nvim_create_autocmd('TermOpen', {
    group = vim.api.nvim_create_augroup('ConfigureTerminal', { clear = true }),
    pattern = '*',
    callback = function()
      vim.cmd.setlocal 'nonumber'
      vim.cmd.setlocal 'norelativenumber'
    end,
  })

  -- highlight text on yank
  vim.api.nvim_create_autocmd('TextYankPost', {
    group = vim.api.nvim_create_augroup('HighlighYank', { clear = true }),
    pattern = "*",
    callback = function()
      vim.highlight.on_yank { timeout = 100 }
    end,
  })

  -- NOTE: Uncomment if you want this to remove extra spaces on a line automatically
  -- vim.api.nvim_create_autocmd('BufWritePre', {
  --   group = vim.api.nvim_create_augroup('BufferFormattingGroup', { clear = true }),
  --   pattern = '*',
  --   command = '%s/\\s\\+$//e'
  -- })

  -- count how many windows are being used for editing
  local function is_essential(filetype)
    return not vim.tbl_contains({ 'help', 'neo-tree', 'qf', 'toggleterm' }, filetype)
  end

  local function count_essential(layout)
    if layout[1] == 'leaf' then
      local ft = vim.api.nvim_buf_get_option(vim.api.nvim_win_get_buf(layout[2]), 'filetype')
      return is_essential(ft) and 1 or 0, ft == 'toggleterm' and 1 or 0
    end

    local essential, tterm = 0, 0
    for _, value in ipairs(layout[2]) do
      local e, t = count_essential(value)
      essential = essential + e
      tterm = tterm + t
    end
    return essential, tterm
  end

  -- close gracefully if the only remaining useful window is closed
  vim.api.nvim_create_autocmd('QuitPre', {
    group = vim.api.nvim_create_augroup('GracefulExit', { clear = true }),
    pattern = '*',
    callback = function()
      if not is_essential(vim.bo.filetype) then
        return
      end

      local essential, tterm = count_essential(vim.fn.winlayout())
      if essential ~= 1 then
        return
      end

      vim.cmd.cclose()
      vim.cmd "silent! Neotree close"

      if tterm > 0 then
        vim.cmd "silent! ToggleTermToggleAll!"
      end
    end,
  })
end
