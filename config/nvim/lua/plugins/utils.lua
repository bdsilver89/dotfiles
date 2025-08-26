return {
	"nvim-lua/plenary.nvim",

	{
		"NMAC427/guess-indent.nvim",
		cmd = "GuessIndent",
		opts = {
			auto_cmd = false,
		},
		init = function(_, _)
			vim.api.nvim_create_autocmd("BufReadPost", {
				callback = function(ev)
					require("guess-indent").set_from_buffer(ev.buf, true, true)
				end,
			})
			vim.api.nvim_create_autocmd("BufNewFile", {
				callback = function(ev)
					vim.api.nvim_create_autocmd("BufNewFile", {
						buffer = ev.buf,
						callback = function(ev2)
							require("guess-indent").set_from_buffer(ev2.buf, true, true)
						end,
					})
				end,
			})
		end,
	},
}
