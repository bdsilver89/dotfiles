require('toggleterm').setup({
	size = function (term)
   	if term.direction == "horizontal" then
      return vim.o.lines * 0.25
  	elseif term.direction == "vertical" then
      return vim.o.columns * 0.40  
	  end
	end,
  on_open = function()
   	vim.api.nvim_set_option_value("foldmethod", "manual", { scope = "local" })
	  vim.api.nvim_set_option_value("foldexpr", "0", { scope = "local" })
  end,
	open_mapping = false,
	hide_numbers = true,
	shade_filetypes = {},
	shade_terminals = false,
	shading_factor = "1",
	start_in_insert = true,
	insert_mappings = true,
	persist_size = true,
	direction = "horizontal",
	close_on_exit = true,
	shell = vim.o.shell,
})
