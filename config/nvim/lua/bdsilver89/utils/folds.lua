local M = {}

M.skip_foldexpr = {} ---@type table<number,boolean>
local skip_check = assert(vim.uv.new_check())

function M.foldtext()
	local ok = pcall(vim.treesitter.get_parser, vim.api.nvim_get_current_buf())
	local ret = ok and vim.treesitter.foldtext and vim.treesitter.foldtext()
	if not ret or type(ret) == "string" then
		ret = { { vim.api.nvim_buf_get_lines(0, vim.v.lnum - 1, vim.v.lnum, false)[1], {} } }
	end
	table.insert(ret, { " " .. require("bdsilver89.utils").ui.get_icon("misc", "Dots") })

	if not vim.treesitter.foldtext then
		return table.concat(
			vim.tbl_map(function(line)
				return line[1]
			end, ret),
			" "
		)
	end
	return ret
end

function M.foldexpr()
	local buf = vim.api.nvim_get_current_buf()

	if M.skip_foldexpr[buf] then
		return "0"
	end

	if vim.bo[buf].buftype ~= "" then
		return "0"
	end

	local ok = pcall(vim.treesitter.get_parser, buf)
	if ok then
		return vim.treesitter.foldexpr()
	end

	M.skip_foldexpr[buf] = true
	skip_check:start(function()
		M.skip_foldexpr = {}
		skip_foldexpr:stop()
	end)
	return "0"
end

return M
