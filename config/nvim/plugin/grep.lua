local function grep(opts)
  local args = opts.args
  local grepcmd
  local s, n = vim.o.grepprg:gsub("%$%*", args)
  if n == 0 then
    grepcmd = s .. " " .. args
  else
    grepcmd = s
  end

  vim.api.nvim_exec_autocmds("QuickFixCmdPre", { pattern = "grep", modeline = false })

  local function callback(result)
    local code = result.code
    local stdout = result.stdout
    local stderr = result.stderr
    local src = code == 0 and stdout or stderr
    local lines = vim.split(src, "\n", { trimempty = true })

    vim.schedule(function()
      vim.fn.setqflist({}, " ", {
        title = grepcmd,
        lines = lines,
        efm = vim.o.grepformat,
        nr = "$",
      })
      vim.api.nvim_exec_autocmds("QuickFixCmdPost", { pattern = "grep", modeline = false })
    end)
  end

  vim.system({ vim.o.shell, "-c", grepcmd }, callback)
  print(grepcmd)
end

vim.api.nvim_create_user_command("Grep", grep, { nargs = "+", complete = "file_in_path" })

vim.api.nvim_create_augroup("grep#", { clear = true })
vim.api.nvim_create_autocmd("QuickFixCmdPost", {
  group = "grep#",
  pattern = "grep",
  nested = true,
  callback = function()
    local list = vim.fn.getqflist()
    vim.cmd("cclose|botright " .. math.min(10, #list) .. "cwindow")
  end,
})

vim.keymap.set("ca", "gr", function()
  if vim.fn.getcmdtype() == ":" and vim.fn.getcmdline() == "gr" then
    return "Grep"
  else
    return "gr"
  end
end, { expr = true, silent = false })

vim.keymap.set("ca", "grep", function()
  if vim.fn.getcmdtype() == ":" and vim.fn.getcmdline() == "grep" then
    return "Grep"
  else
    return "grep"
  end
end, { expr = true, silent = false })

vim.keymap.set("n", "<leader>/", ":Grep ", { silent = false })
vim.keymap.set("x", "<leader>/", 'y:<C-U>Grep <C-R>"', { silent = false })
vim.keymap.set("n", "<leader>*", ":Grep <C-R><C-W><CR>")
vim.keymap.set("x", "<leader>*", 'y:<C-U>Grep <C-R>"<CR>')
--
