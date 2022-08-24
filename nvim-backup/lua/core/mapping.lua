local bind = require("keymap.bind")
local map_cr = bind.map_cr
local map_cu = bind.map_cu
local map_cmd = bind.map_cmd

-- default map
local def_map = {
	-- ["n|x"] = map_cmd("_x"):with_noremap(),
	-- Increment/decrement
	["n|+"] = map_cmd("<C-a>"):with_noremap(),
	["n|-"] = map_cmd("<C-x>"):with_noremap(),
	-- Select all
	["n|<C-a>"] = map_cmd("gg<S-v>G"):with_noremap(),
	-- Tabs
	["n|te"] = map_cmd(":tabedit"):with_noremap(),
	["n|tc"] = map_cmd(":tabclose"):with_noremap(),
	-- Splits
	["n|ss"] = map_cmd(":split<Return><C-w>w"):with_noremap(),
	["n|sv"] = map_cmd(":vsplit<Return><C-w>w"):with_noremap(),
	-- Move window
	["n|<Space>"] = map_cmd("<C-w>w"):with_noremap(),
	["n|sh"] = map_cmd("<C-w>h"):with_noremap(),
	["n|sj"] = map_cmd("<C-w>j"):with_noremap(),
	["n|sk"] = map_cmd("<C-w>k"):with_noremap(),
	["n|sl"] = map_cmd("<C-w>l"):with_noremap(),
	-- Resize window
	["n|<C-w><left>"] = map_cmd("<C-w>10<"):with_noremap(),
	["n|<C-w><right>"] = map_cmd("<C-w>10>"):with_noremap(),
	["n|<C-w><up>"] = map_cmd("<C-w>10+"):with_noremap(),
	["n|<C-w><down>"] = map_cmd("<C-w>10-"):with_noremap(),
}

bind.nvim_load_mapping(def_map)
