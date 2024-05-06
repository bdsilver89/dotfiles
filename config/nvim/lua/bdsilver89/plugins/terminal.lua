return {
	{
		"akinsho/toggleterm.nvim",
		cmd = { "ToggleTerm", "TermExec" },
		keys = function()
			local keys = {
				{ "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", desc = "Toggleterm float" },
				{ "<leader>th", "<cmd>ToggleTerm size=10 direction=horizontal<cr>", desc = "Toggleterm horizontal" },
				{ "<leader>tv", "<cmd>ToggleTerm size=80 direction=vertical<cr>", desc = "Toggleterm vertical" },
				-- TODO: extra keymaps for executing and toggling
			}

			if vim.fn.executable("lazygit") == 1 then
				keys[#keys + 1] = {
					"<leader>gg",
					function()
						require("bdsilver89.utils").term.cmd("lazygit")
					end,
					desc = "Toggleterm lazygit"
				}
			end
			if vim.fn.executable("node") == 1 then
				keys[#keys + 1] = {
					"<leader>tn",
					function()
						require("bdsilver89.utils").term.cmd("node")
					end,
					desc = "Toggleterm node"
				}
			end
			local python = vim.fn.executable("python") == 1 and "python" or vim.fn.executable("python3") == 1 and "python3"
			if python then
				keys[#keys + 1] = {
					"<leader>tp",
					function()
						require("bdsilver89.utils").term.cmd(python)
					end,
					desc = "Toggleterm python"
				}
			end
			return keys
		end,
		opts = {
			highlights = {
				Normal = { link = "Normal" },
				NormalNC = { link = "NormalNC" },
				NormalFloat = { link = "NormalFloat" },
				FloatBorder = { link = "FloatBorder" },
				StatusLine = { link = "StatusLine" },
				StatusLineNC = { link = "StatusLineNC" },
				WinBar = { link = "WinBar" },
				WinBarNC = { link = "WinBarNC" },
			},
			size = 10,
			---@param t Terminal
			on_create = function(t)
				vim.opt_local.foldcolumn = "0"
				vim.opt_local.signcolumn = "no"
				if t.hidden then
					local toggle = function() t:toggle() end
					vim.keymap.set({ "n", "t", "i" }, "<C-'>", toggle, { desc = "Toggle terminal", buffer = t.bufnr })
					vim.keymap.set({ "n", "t", "i" }, "<F7>", toggle, { desc = "Toggle terminal", buffer = t.bufnr })
				end
			end,
			shading_factor = 2,
			direction = "float",
			float_opts = { border = "rounded" },
		},
	}
}


