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
  { '<TAB>', _G.smart_tab, opts(expr, silent, remap) },
  { '<S-TAB>', _G.smart_shift_tab, opts(expr, silent, remap) },
})

nmap({
  -- packer
  { '<Leader>pu', cmd('PackerUpdate'), opts(noremap, silent) },
  { '<Leader>pi', cmd('PackerInstall'), opts(noremap, silent) },
  { '<Leader>pc', cmd('PackerCompile'), opts(noremap, silent) },
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
  { '<Leader>fg', cmd('Telescope gif_files'), opts(noremap, silent) },
  { '<Leader>fw', cmd('Telescope grep_string'), opts(noremap, silent) },
  { '<Leader>fh', cmd('Telescope help_tags'), opts(noremap, silent) },
  { '<Leader>fo', cmd('Telescope oldfiles'), opts(noremap, silent) },
  { '<Leader>gc', cmd('Telescope git_commits'), opts(noremap, silent) },
  { '<Leader>gc', cmd('Telescope dotfiles path' .. home .. '/.dotfiles'), opts(noremap, silent) },
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
	-- { '<C-\\>', ':[[execute v:count . "ToggleTerm direction=horizontal"]]<CR>', opts(noremap, silent) },
	-- { '<F5>', cmd('ToggleTerm direction=vertical'), opts(noremap, silent) },
	-- { '<A-d>', cmd('ToggleTerm direction=float'), opts(noremap, silent) },
  -- bufferline
  { '<Leader>gb', cmd('BufferLinePick'), opts(noremap, silent) },
  { '<Tab>', cmd('BufferLineCycleNext'), opts(noremap, silent) },
  { '<S-Tab>', cmd('BufferLineCyclePrev'), opts(noremap, silent) },
  -- { '<A-Tab>', cmd('BufferLineMoveNext'), opts(norempa, silent) },
  -- { '<A-S-Tab>', cmd('BufferLineMoveNext'), opts(norempa, silent) },
  { '<A-1>', cmd('BufferLineGoToBuffer 1'), opts(norempa, silent)},
  { '<A-2>', cmd('BufferLineGoToBuffer 2'), opts(norempa, silent)},
  { '<A-3>', cmd('BufferLineGoToBuffer 3'), opts(norempa, silent)},
  { '<A-4>', cmd('BufferLineGoToBuffer 4'), opts(norempa, silent)},
  { '<A-5>', cmd('BufferLineGoToBuffer 5'), opts(norempa, silent)},
  { '<A-6>', cmd('BufferLineGoToBuffer 6'), opts(norempa, silent)},
  { '<A-7>', cmd('BufferLineGoToBuffer 7'), opts(norempa, silent)},
  { '<A-8>', cmd('BufferLineGoToBuffer 8'), opts(norempa, silent)},
  { '<A-9>', cmd('BufferLineGoToBuffer 9'), opts(norempa, silent)},
})

nmap({ 'gcc', cmd('ComComment'), opts(noremap, silent) })
xmap({ 'gcc', ':ComComment<CR>', opts(noremap, silent) })
nmap({ 'gcj', cmd('ComAnnotation'), opts(noremap, silent) })

tmap({ '<A-d>', [[<C-\><C-n>:Lspsaga close_floaterm<CR>]], opts(noremap, silent) })

xmap({ 'ga', cu('Lspsaga code_action'), opts(noremap, silent) })
