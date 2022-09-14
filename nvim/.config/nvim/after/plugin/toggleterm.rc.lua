local status, toggleterm = pcall(require, 'toggleterm')
if (not status) then return end

local Remap = require('bdsilver89.keymap')
local nnoremap = Remap.nnoremap
local tnoremap = Remap.tnoremap
local inoremap = Remap.inoremap


toggleterm.setup({
	-- size can be a number or function which is passed the current terminal
	size = function(term)
	  if term.direction == "horizontal" then
			return 15
		elseif term.direction == "vertical" then
			return vim.o.columns * 0.40
		end
	end,
	on_open = function()
		-- Prevent infinite calls from freezing neovim.
		-- Only set these options specific to this terminal buffer.
		vim.api.nvim_set_option_value("foldmethod", "manual", { scope = "local" })
		vim.api.nvim_set_option_value("foldexpr", "0", { scope = "local" })
	end,
	open_mapping = false, -- [[<c-\>]],
	hide_numbers = true, -- hide the number column in toggleterm buffers
	shade_filetypes = {},
	shade_terminals = false,
	shading_factor = "1", -- the degree by which to darken to terminal colour, default: 1 for dark backgrounds, 3 for light
	start_in_insert = true,
	insert_mappings = true, -- whether or not the open mapping applies in insert mode
	persist_size = true,
	direction = "vertical",
	close_on_exit = true, -- close the terminal window when the process exits
	shell = vim.o.shell, -- change the default shell
})

vim.api.nvim_create_autocmd('TermOpen', {
  pattern = 'term://*',
  callback = function()
    local opts = { buffer = 0 }
    tnoremap('<Esc>', [[<C-\><C-n>]], opts)
    tnoremap('<C-h>', [[<Cmd>wincmd h<CR>]], opts)
    tnoremap('<C-j>', [[<Cmd>wincmd j<CR>]], opts)
    tnoremap('<C-k>', [[<Cmd>wincmd k<CR>]], opts)
    tnoremap('<C-l>', [[<Cmd>wincmd l<CR>]], opts)
  end,
})

vim.api.nvim_create_autocmd('TermEnter', {
  pattern = 'term://*toggleterm*',
  callback = function()
    local opts = { silent = true }
    tnoremap('<C-t>', [[<Cmd>exe v:count1 . "ToggleTerm"<CR>]], opts)
  end,
})

local opts = { silent = true }
nnoremap('<C-t>', [[<Cmd>exe v:count1 . "ToggleTerm"<CR>]], opts)
inoremap('<C-t>', [[<Esc><Cmd>exe v:count1 . "ToggleTerm"<CR>]], opts)
