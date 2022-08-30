require('keymap.remap')
local keymap = require('core.keymap')
local nmap, imap, xmap, tmap = keymap.nmap, keymap.imap, keymap.xmap, keymap.tmap
local silent, noremap, expr, remap = keymap.silent, keymap.noremap, keymap.expr, keymap.remap
local opts = keymap.new_opts
local cmd, cu = keymap.cmd, keymap.cu
local home = os.getenv('HOME')
require('keymap.config')

imap({
  -- tab key
  -- { '<TAB>', _G.smart_tab, opts(expr, silent, remap) },
  -- { '<S-TAB>', _G.smart_shift_tab, opts(expr, silent, remap) },
  { '<C-\\>', cmd('<Esc><cmd>ToggleTerm direction=horizontal<CR>'), opts(noremap, silent)},
  { '<F6>', cmd('<Esc><cmd>ToggleTerm direction=vertical<CR>'), opts(noremap, silent) },
	{ '<A-d>', cmd('<Esc><cmd>ToggleTerm direction=float<CR>'), opts(noremap, silent) },
})

tmap({
  { '<Esc><Esc>', [[<C-\><C-n>]], opts(noremap) },
  { '<C-\\>', [[<C-\><C-n><cmd>ToggleTerm<CR>]], opts(noremap, silent)},
  { '<F6>', [[<C-\><C-n><cmd>ToggleTerm direction=vertical<CR>]], opts(noremap, silent) },
  { '<A-d>', [[<C-\><C-n><cmd>ToggleTerm direction=float<CR>]], opts(noremap, silent) },
})

nmap({
  -- packer
  { '<Leader>pu', cmd('PackerUpdate'), opts(noremap, silent) },
  { '<Leader>pi', cmd('PackerInstall'), opts(noremap, silent) },
  { '<Leader>pc', cmd('PackerCompile'), opts(noremap, silent) },
  { '<Leader>ps', cmd('PackerSync'), opts(noremap, silent) },
  -- Lsp
  { '<Leader>li', cmd('LspInfo'), opts(noremap, silent) },
  { '<Leader>ll', cmd('LspLog'), opts(noremap, silent) },
  { '<Leader>lr', cmd('LspRestart'), opts(noremap, silent) },
  {
    '<C-f>',
    cmd('lua require("lspsaga.action").smart_scroll_with_saga(1)'),
    opts(noremap, silent),
  },
  {
    '<C-b>',
    cmd('lua require("lspsaga.action"").smart_scroll_with_saga(-1)'),
    opts(noremap, silent),
  },
  -- Lspsaga
  { '[e', cmd('Lspsaga diagnostic_jump_next'), opts(noremap, silent) },
  { ']e', cmd('Lspsaga diagnostic_jump_prev'), opts(noremap, silent) },
  { 'K', cmd('Lspsaga hover_doc'), opts(noremap, silent) },
  { 'ga', cmd('Lspsaga code_action'), opts(noremap, silent) },
  { 'gd', cmd('Lspsaga preview_definition'), opts(noremap, silent) },
  { 'gs', cmd('Lspsaga signature_help'), opts(noremap, silent) },
  { 'gr', cmd('Lspsaga rename'), opts(noremap, silent) },
  { 'gh', cmd('Lspsaga lsp_finder'), opts(noremap, silent) },
  { '<Leader>o', cmd('LSoutlineToggle'), opts(noremap, silent) },
  -- Lspsaga floaterminal
  -- { '<A-d>', cmd('Lspsaga open_floaterm'), opts(noremap, silent) },
  -- { '<Leader>g', cmd('Lspsaga open_floaterm lazygit'), opts(noremap, silent) },
  -- dashboard create file
  { '<Leader>n', cmd('DashboardNewFile'), opts(noremap, silent) },
  { '<Leader>ss', cmd('SessionSave'), opts(noremap, silent) },
  { '<Leader>sl', cmd('SessionLoad'), opts(noremap, silent) },
  -- nvimtree
  { '<Leader>e', cmd('NvimTreeToggle'), opts(noremap, silent) },
  -- dadbodui
  { '<Leader>d', cmd('DBUIToggle'), opts(noremap, silent) },
  -- Telescope
  { '<Leader>b', cmd('Telescope buffers'), opts(noremap, silent) },
  { '<Leader>fa', cmd('Telescope live_grep'), opts(noremap, silent) },
  { '<Leader>fb', cmd('Telescope file_browser'), opts(noremap, silent) },
  { '<Leader>fd', cmd('Telescope dotfiles'), opts(noremap, silent) },
  { '<Leader>ff', cmd('Telescope find_files'), opts(noremap, silent) },
  { '<Leader>fg', cmd('Telescope git_files'), opts(noremap, silent) },
  { '<Leader>fw', cmd('Telescope grep_string'), opts(noremap, silent) },
  { '<Leader>fh', cmd('Telescope help_tags'), opts(noremap, silent) },
  { '<Leader>fo', cmd('Telescope oldfiles'), opts(noremap, silent) },
  { '<Leader>gc', cmd('Telescope git_commits'), opts(noremap, silent) },
  { '<Leader>gc', cmd('Telescope dotfiles path' .. home .. '/.dotfiles'), opts(noremap, silent) },
  { '<Leader>fp', cmd('Telescope project'), opts(noremap, silent) },
  { '<Leader>fr', cmd('Telescope frecency'), opts(noremap, silent)},
  -- vim-operator-surround
  { 'sa', '<Plug>(operator-surround-append)', opts(noremap, silent) },
  { 'sd', '<Plug>(operator-surround-delete)', opts(noremap, silent) },
  { 'sr', '<Plug>(operator-surround-replace)', opts(noremap, silent) },
  -- formatter
  { '<Leader>f', cmd('Format'), opts(noremap, silent) },
  { '<Leader>F', cmd('FormatWrite'), opts(noremap, silent)},
  -- undotree
  { '<Leader>u', cmd("UndotreeToggle"), opts(noremap, silent) },
  -- trouble
  { 'gt', cmd('TroubleToggle'), opts(noremap, silent) },
  { 'gR', cmd('TroubleToggle lsp_references'), opts(noremap, silent) },
  { '<Leader>cd', cmd('TroubleToggle document_diagnostics'), opts(noremap, silent) },
  { '<Leader>cw', cmd('TroubleToggle workspace_diagnostics'), opts(noremap, silent) },
  { '<Leader>cq', cmd('TroubleToggle quickfix'), opts(noremap, silent) },
  { '<Leader>cl', cmd('TroubleToggle loclist'), opts(noremap, silent) },
	-- toggleterm
	{ '<C-\\>', cmd('ToggleTerm direction=horizontal'), opts(noremap, silent) },
	{ '<F6>', cmd('ToggleTerm direction=vertical'), opts(noremap, silent) },
	{ '<A-d>', cmd('ToggleTerm direction=float'), opts(noremap, silent) },
  -- bufferline
  { '<Leader>gb', cmd('BufferLinePick'), opts(noremap, silent) },
  { '<Tab>', cmd('BufferLineCycleNext'), opts(noremap, silent) },
  { '<S-Tab>', cmd('BufferLineCyclePrev'), opts(noremap, silent) },
  -- { '<A-Tab>', cmd('BufferLineMoveNext'), opts(noremap, silent) },
  -- { '<A-S-Tab>', cmd('BufferLineMoveNext'), opts(noremap, silent) },
  { '<A-1>', cmd('BufferLineGoToBuffer 1'), opts(noremap, silent)},
  { '<A-2>', cmd('BufferLineGoToBuffer 2'), opts(noremap, silent)},
  { '<A-3>', cmd('BufferLineGoToBuffer 3'), opts(noremap, silent)},
  { '<A-4>', cmd('BufferLineGoToBuffer 4'), opts(noremap, silent)},
  { '<A-5>', cmd('BufferLineGoToBuffer 5'), opts(noremap, silent)},
  { '<A-6>', cmd('BufferLineGoToBuffer 6'), opts(noremap, silent)},
  { '<A-7>', cmd('BufferLineGoToBuffer 7'), opts(noremap, silent)},
  { '<A-8>', cmd('BufferLineGoToBuffer 8'), opts(noremap, silent)},
  { '<A-9>', cmd('BufferLineGoToBuffer 9'), opts(noremap, silent)},
  -- hop
  { '<Leader>w', cmd('HopWord'), opts(noremap)},
  { '<Leader>j', cmd('HopLine'), opts(noremap)},
  { '<Leader>k', cmd('HopLine'), opts(noremap)},
  { '<Leader>c', cmd('HopChar1'), opts(noremap)},
  { '<Leader>cc', cmd('HopChar2'), opts(noremap)},
  -- dap
  { '<F4>', cmd('lua require("dapui").toggle()'), opts(noremap) },
  { '<F5>', cmd('lua require("dap").toggle_breakpoint()'), opts(noremap) },
  { '<F9>', cmd('lua require("dap").continue()'), opts(noremap) },

  { '<F1>', cmd('lua require("dap").step_over()'), opts(noremap) },
  { '<F2>', cmd('lua require("dap").step_into()'), opts(noremap) },
  { '<F3>', cmd('lua require("dap").step_out()'), opts(noremap) },

  { '<Leader>dsc', cmd('lua require("dap").continue()'), opts(noremap) },
  { '<Leader>dsv', cmd('lua require("dap").step_over()'), opts(noremap) },
  { '<Leader>dsi', cmd('lua require("dap").step_into()'), opts(noremap) },
  { '<Leader>dso', cmd('lua require("dap").step_out()'), opts(noremap) },

  { '<Leader>dhh', cmd('lua require("dap.ui.variables").hover()'), opts(noremap) },
  { '<Leader>dhv', cmd('lua require("dap.ui.variables").visual_hover()'), opts(noremap) },

  { '<Leader>duh', cmd('lua require("dap.ui.widgets").hover()'), opts(noremap) },
  { '<Leader>duf', cmd('lua local widgets=require("dap.ui.widgets");widgets.centered_float(widgets.scopes)'), opts(noremap) },

  { '<Leader>dro', cmd('lua require("dap").repl.open()'), opts(noremap) },
  { '<Leader>drl', cmd('lua require("dap").repl.run_last()'), opts(noremap) },

  { '<Leader>dbc', cmd('lua require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))'), opts(noremap) },
  { '<Leader>dbm', cmd('lua require("dap").set_breakpoint({ nil, nil, vim.fn.input("log point message: ") })') , opts(noremap) },
  { '<Leader>dbt', cmd('lua require("dap").toggle_breakpoint()'), opts(noremap) },

  { '<Leader>dc', cmd('lua require("dap.ui.variables").scopes()'), opts(noremap) },
  { '<Leader>di', cmd('lua require("dapui").toggle()'), opts(noremap) },

  -- neotest
  { '<Leader>tr', cmd('lua require("neotest").run.run()'), opts(noremap) },
  { '<Leader>tf', cmd('lua require("neotest").run.run(vim.expand("%"))'), opts(noremap) },
  { '<Leader>trd', cmd('lua require("neotest").run.run({strategy="dap"})'), opts(noremap) },
  { '<Leader>ts', cmd('lua require("neotest).run.stop()'), opts(noremap) },
  { '<Leader>ta', cmd('lua require("neotest").run.attach()'), opts(noremap) },
})
