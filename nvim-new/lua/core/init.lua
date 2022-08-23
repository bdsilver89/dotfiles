local global = require("core.global")
local vim = vim

-- Create cache dir and subs dir
local createdir = function()
	local data_dir = {
		global.cache_dir .. "backup",
		global.cache_dir .. "session",
		global.cache_dir .. "swap",
		global.cache_dir .. "tags",
		global.cache_dir .. "undo",
	}
	-- There only check once that If cache_dir exists
	-- Then I don't want to check subs dir exists
	if vim.fn.isdirectory(global.cache_dir) == 0 then
		os.execute("mkdir -p " .. global.cache_dir)
		for _, v in pairs(data_dir) do
			if vim.fn.isdirectory(v) == 0 then
				os.execute("mkdir -p " .. v)
			end
		end
	end
end

local disable_distribution_plugins = function()
	vim.g.did_load_filetypes = 1
	vim.g.did_load_fzf = 1
	vim.g.did_load_gtags = 1
	vim.g.did_load_gzip = 1
	vim.g.did_load_tar = 1
	vim.g.did_load_tarPlugin = 1
	vim.g.did_load_zip = 1
	vim.g.did_load_zipPlugin = 1
	vim.g.did_load_getscript = 1
	vim.g.did_load_getscriptPlugin = 1
	vim.g.did_load_vimball = 1
	vim.g.did_load_vimballPlugin = 1
	vim.g.did_load_matchit = 1
	vim.g.did_load_matchparen = 1
	vim.g.did_load_2html_plugin = 1
	vim.g.did_load_logiPat = 1
	vim.g.did_load_rrhelper = 1
	vim.g.did_load_netrw = 1
	vim.g.did_load_netrwPlugin = 1
	vim.g.did_load_netrwSettings = 1
	vim.g.did_load_netrwFileHandlers = 1
end

local leader_map = function()
	vim.g.mapleader = " "
end

local load_core = function()
	local install_path = vim.fn.stdpath "data" .. "/site/pack/packer/opt/packer.nvim"
	if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
		vim.api.nvim_set_hl(0, "NormalFloat", {})
		print 'Cloning packer...'
		vim.fn.system {"git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim", install_path}
		vim.cmd "packadd packer.nvim"
	end
-- 	local packer = require("core.packer")
--	createdir()
--	disable_distribution_plugins()
--	leader_map()

--	packer.ensure_plugins()
--	require("core.options")
--	require("core.mapping")
--	require("keymap")
--	require("core.event")
--	packer.load_compile()
end

load_core()
