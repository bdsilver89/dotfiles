local bind = require("keymap.bind")
local map_cr = bind.map_cr
local map_cu = bind.map_cu
local map_cmd = bind.map_cmd
require("keymap.config")

local plug_map = {
    -- Bufferline
    ["n|<Tab>"] = map_cmd("<Cmd>BufferLineCycleNext<CR>"):with_noremap(),
    ["n|<S-Tab>"] = map_cmd("<Cmd>BufferLineCyclePrev<CR>"):with_noremap(),

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
		"lua require('telescope').extensions.file_browser.file_browser({path = '%:p:h', cwd = '%:p:h' })"
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

	-- nvim-tree
	["n|<C-n>"] = map_cr("NvimTreeToggle"):with_noremap():with_silent(),
	["n|<Leader>nf"] = map_cr("NvimTreeFindFile"):with_noremap():with_silent(),
	["n|<Leader>nr"] = map_cr("NvimTreeRefresh"):with_noremap():with_silent(),

    -- Lsp
    ["n|gd"] = map_cr("Lspsaga preview_definition"):with_noremap():with_silent(),

    -- UndoTree
    -- ["n|<Leader>u"] = map_cmd("<Cmd>UndotreeToggle<CR>"):with_noremap():with_silent(),

    -- ZenMode
    ["n|<C-w>o"] = map_cmd("<cmd>ZenMode<cr>"):with_noremap():with_silent(),
}

bind.nvim_load_mapping(plug_map)
