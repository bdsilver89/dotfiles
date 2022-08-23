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
    ["n|ff"] = map_cu("Telescope find_files"),
    ["n|fe"] = map_cu("Telescope oldfiles"),
    ["n|fs"] = map_cu(
		"lua require('telescope').extensions.file_browser.file_browser({path = '%:p:h', cwd = '%:p:h' })"
	),

    -- Lsp
    ["n|gd"] = map_cr("Lspsaga preview_definition"):with_noremap():with_silent(),

    -- UndoTree
    -- ["n|<Leader>u"] = map_cmd("<Cmd>UndotreeToggle<CR>"):with_noremap():with_silent(),

    -- ZenMode
    ["n|<C-w>o"] = map_cmd("<cmd>ZenMode<cr>"):with_noremap():with_silent(),
}

bind.nvim_load_mapping(plug_map)
