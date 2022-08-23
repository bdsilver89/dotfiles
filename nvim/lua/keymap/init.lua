local bind = require("keymap.bind")
local map_cr = bind.map_cr
local map_cu = bind.map_cu
local map_cmd = bind.map_cmd
require("keymap.config")

local plug_map = {
  -- Packer
  ["n|<leader>ps"] = map_cr("PackerSync"):with_noremap():with_silent():with_nowait(),
  ["n|<leader>pu"] = map_cr("PackerUpdate"):with_noremap():with_silent():with_nowait(),
  ["n|<leader>pi"] = map_cr("PackerInstall"):with_noremap():with_silent():with_nowait(),
  ["n|<leader>pc"] = map_cr("PackerClean"):with_noremap():with_silent():with_nowait(),

  -- Bufferline
  ["n|<Tab>"] = map_cr("BufferLineCycleNext"):with_noremap():with_silent(),
  ["n|<S-Tab>"] = map_cr("BufferLineCyclePrev"):with_noremap():with_silent(),
  ["n|<leader>be>"] = map_cr("BufferLineSortByExtension"):with_noremap(),
  ["n|<leader>bd>"] = map_cr("BufferLineSortByDirectory"):with_noremap(),
  ["n|<A-1>]"] = map_cr("BufferLineGoToBuffer 1"):with_noremap():with_silent(),
  ["n|<A-2>]"] = map_cr("BufferLineGoToBuffer 2"):with_noremap():with_silent(),
  ["n|<A-3>]"] = map_cr("BufferLineGoToBuffer 3"):with_noremap():with_silent(),
  ["n|<A-4>]"] = map_cr("BufferLineGoToBuffer 4"):with_noremap():with_silent(),
  ["n|<A-5>]"] = map_cr("BufferLineGoToBuffer 5"):with_noremap():with_silent(),
  ["n|<A-6>]"] = map_cr("BufferLineGoToBuffer 6"):with_noremap():with_silent(),
  ["n|<A-7>]"] = map_cr("BufferLineGoToBuffer 7"):with_noremap():with_silent(),
  ["n|<A-8>]"] = map_cr("BufferLineGoToBuffer 8"):with_noremap():with_silent(),
  ["n|<A-9>]"] = map_cr("BufferLineGoToBuffer 9"):with_noremap():with_silent(),

	-- Telescope
	["n|<Leader>fp"] = map_cu("lua require('telescope').extensions.project.project{}"):with_noremap():with_silent(),
	["n|<Leader>fr"] = map_cu("lua require('telescope').extensions.frecency.frecency{}"):with_noremap():with_silent(),
	["n|<Leader>fe"] = map_cu("Telescope oldfiles"):with_noremap():with_silent(),
	["n|<Leader>ff"] = map_cu("Telescope find_files"):with_noremap():with_silent(),
	["n|<Leader>sc"] = map_cu("Telescope colorscheme"):with_noremap():with_silent(),
	["n|<Leader>fn"] = map_cu(":enew"):with_noremap():with_silent(),
	["n|<Leader>fw"] = map_cu("Telescope live_grep"):with_noremap():with_silent(),
	["n|<Leader>fg"] = map_cu("Telescope git_files"):with_noremap():with_silent(),
	["n|<Leader>fz"] = map_cu("Telescope zoxide list"):with_noremap():with_silent(),
	["n|<Leader>fs"] = map_cu(
		"lua require('telescope').extensions.file_browser.file_browser({path = '%:p:h', cwd = '%:p:h', respect_gitignore = false, hidden = true, grouped = true, previewer = false, initial_mode = 'normal', layout_config = { height = 40 } })"
	),

	-- ToggleTerm
	-- ["t|<Esc><Esc>"] = map_cmd([[<C-\><C-n>]]), -- switch to normal mode in terminal.
	["n|<C-\\>"] = map_cr([[execute v:count . "ToggleTerm direction=horizontal"]]):with_noremap():with_silent(),
	["i|<C-\\>"] = map_cmd("<Esc><Cmd>ToggleTerm direction=horizontal<CR>"):with_noremap():with_silent(),
	["t|<C-\\>"] = map_cmd("<Esc><Cmd>ToggleTerm<CR>"):with_noremap():with_silent(),
	["n|<C-w>t"] = map_cr([[execute v:count . "ToggleTerm direction=vertical"]]):with_noremap():with_silent(),
	["i|<C-w>t"] = map_cmd("<Esc><Cmd>ToggleTerm direction=vertical<CR>"):with_noremap():with_silent(),
	["t|<C-w>t"] = map_cmd("<Esc><Cmd>ToggleTerm<CR>"):with_noremap():with_silent(),
	["n|<F5>"] = map_cr([[execute v:count . "ToggleTerm direction=vertical"]]):with_noremap():with_silent(),
	["i|<F5>"] = map_cmd("<Esc><Cmd>ToggleTerm direction=vertical<CR>"):with_noremap():with_silent(),
	["t|<F5>"] = map_cmd("<Esc><Cmd>ToggleTerm<CR>"):with_noremap():with_silent(),
	["n|<A-d>"] = map_cr([[execute v:count . "ToggleTerm direction=float"]]):with_noremap():with_silent(),
	["i|<A-d>"] = map_cmd("<Esc><Cmd>ToggleTerm direction=float<CR>"):with_noremap():with_silent(),
	["t|<A-d>"] = map_cmd("<Esc><Cmd>ToggleTerm<CR>"):with_noremap():with_silent(),
	["n|<leader>g"] = map_cr("lua toggle_lazygit()"):with_noremap():with_silent(),
	["t|<leader>g"] = map_cmd("<Esc><Cmd>lua toggle_lazygit()<CR>"):with_noremap():with_silent(),
	["n|<leader>G"] = map_cu("Git"):with_noremap():with_silent(),

  -- accelerate-jk
  -- ["n|j"] = map_cmd("v:lua.enhance_jk_move('j')"):with_silent():with_expr(),
  -- ["n|k"] = map_cmd("v:lua.enhance_jk_move('k')"):with_silent():with_expr(),
  
  -- Hop
  ["n|<leader>w"] = map_cu("HopWord"):with_noremap(),
  ["n|<leader>j"] = map_cu("HopLine"):with_noremap(),
  ["n|<leader>k"] = map_cu("HopLine"):with_noremap(),
  ["n|<leader>c"] = map_cu("HopChar1"):with_noremap(),
  ["n|<leader>cc"] = map_cu("HopChar2"):with_noremap(),

	-- nvim-tree
	["n|<C-n>"] = map_cr("NvimTreeToggle"):with_noremap():with_silent(),
	["n|<Leader>nf"] = map_cr("NvimTreeFindFile"):with_noremap():with_silent(),
	["n|<Leader>nr"] = map_cr("NvimTreeRefresh"):with_noremap():with_silent(),

  -- Lsp
  ["n|<leader>li"] = map_cr("LspInfo"):with_noremap():with_silent():with_nowait(),
  ["n|<leader>lr"] = map_cr("LspRestart"):with_noremap():with_silent():with_nowait(),
  ["n|g["] = map_cr("Lspsaga diagnostic_jump_next"):with_noremap():with_silent():with_nowait(),
  ["n|g]"] = map_cr("Lspsaga diagnostic_jump_next"):with_noremap():with_silent():with_nowait(),
  ["n|gs"] = map_cr("Lspsaga signature_help"):with_noremap():with_silent():with_nowait(),
  ["n|gr"] = map_cr("Lspsaga signature_rename"):with_noremap():with_silent():with_nowait(),
  ["n|gr"] = map_cr("Lspsaga rename"):with_noremap():with_silent():with_nowait(),
  ["n|K"] = map_cr("Lspsaga hover_doc"):with_noremap():with_silent():with_nowait(),
  ["n|<C-Up>"] = map_cr("lua require('lspsaga.action').smart_scroll_with_saga(-1)"):with_noremap():with_silent(),
  ["n|<C-Down>"] = map_cr("lua require('lspsaga.action').smart_scroll_with_saga(1)"):with_noremap():with_silent(),
  ["n|<leader>ca"] = map_cr("Lspsaga code_action"):with_noremap():with_silent(),
  ["v|<leader>ca"] = map_cr("Lspsaga range_code_action"):with_noremap():with_silent(),
  ["v|gd"] = map_cr("Lspsaga preview_definition"):with_noremap():with_silent(),
  ["v|gD"] = map_cr("lua vim.lsp.buf.definition()"):with_noremap():with_silent(),
  ["v|gh"] = map_cr("Lspsaga lsp_finder"):with_noremap():with_silent(),

  -- UndoTree
  ["n|<leader>u"] = map_cr("UndotreeToggle"):with_noremap():with_silent(),

  -- CommentToggle
  ["n|ct"] = map_cr("CommentToggle"):with_noremap():with_silent(),

  -- ZenMode
  ["n|<C-w>o"] = map_cmd("<cmd>ZenMode<cr>"):with_noremap():with_silent(),
}

bind.nvim_load_mapping(plug_map)
