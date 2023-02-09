return {
  -- file explorer
  {
    'nvim-neo-tree/neo-tree.nvim',
    cmd = 'Neotree',
    keys = {
      {
        '<leader>fe',
        function()
          require('neo-tree.command').execute({ toggle = true,  dir = require('util').get_root() })
        end,
        desc = 'Explorer NeoTree (root dir)',
      },
      {
        '<leader>fE',
        function()
          require('neo-tree.command').execute({ toggle = true,  dir = vim.loop.cwd() })
        end,
        desc = 'Explorer NeoTree (cwd)',
      },
      {
        '<leader>e',
	'<leader>fe',
        desc = 'Explorer NeoTree (root dir)',
	remap = true
      },
      {
        '<leader>E',
	'<leader>fE',
        desc = 'Explorer NeoTree (cwd)',
	remap = true
      },
    },
    deactivate = function()
      vim.cmd([[Neotree close]])
    end,
    init = function()
      vim.g.neo_tree_remove_legacy_commands = 1
      if vim.fn.argc() == 1 then
        local stat = vim.loop.fs_stat(vim.fn.argv(0))
	if stat and stat.type == 'directory' then
	  require('neo-tree')
	end
      end
    end,
    opts = {
      filesystem = {
        bind_to_cwd = false,
	follow_current_file = true,
      },
      window = {
        mappings = {
	  ['<space>'] = 'none',
	},
      },
    },
  },

  -- search/replace in multiple files
  {
    'windwp/nvim-spectre',
    keys = {
      {
        '<leader>sr',
	function() require('spectre').open() end,
	desc = 'Replace in files (Spectre)',
      },
    },
  },

  -- telescope
  -- leap
  -- which-key
  -- git-signs
  -- references
  -- buffer remove

  -- trouble diagnostics
  {
    'folke/trouble.nvim',
    cmd = { 'TroubleToggle', 'Trouble' },
    opts = { use_diagnostic_signs = true },
    keys = {
      {
        '<leader>xx',
	'<cmd>TroubleToggle document_diagnostics<cr>',
	desc = 'Document Diagnostics (Trouble)'
      },
      {
        '<leader>xX',
	'<cmd>TroubleToggle workspace_diagnostics<cr>',
	desc = 'Workspace Diagnostics (Trouble)'
      },
      {
        '<leader>xL',
	'<cmd>TroubleToggle loclist<cr>',
	desc = 'Location List (Trouble)'
      },
      {
        '<leader>xQ',
	'<cmd>TroubleToggle quickfix<cr>',
	desc = 'Quickfix List (Trouble)'
      },
    },
  },

  -- todo comments
  {
    'folke/todo-comments.nvim',
    cmd = { 'TodoTrouble', 'TodoTelescope' },
    event = { 'BufReadPost', 'BufNewFile' },
    config = true,
    keys = {
      {
        ']t',
	function() require('todo-comments').jump_next() end,
	desc = 'Next todo comment'
      },
      {
        '[t',
	function() require('todo-comments').jump_prev() end,
	desc = 'Previous todo comment'
      },
      {
        'xt',
	'<cmd>TodoTrouble<cr>',
	desc = 'Todo (Trouble)'
      },
      {
        'xT',
	'<cmd>TodoTrouble keywords=TODO,FIX,FIXME<cr>',
	desc = 'Todo/Fix/Fixme (Trouble)'
      },
      {
        'st',
	'<cmd>TodoTelescope<cr>',
	desc = 'Todo'
      },
    },
  },
}
