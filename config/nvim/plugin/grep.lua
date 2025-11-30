local function grep(opts)
  local args = opts.args
  local grepprg = vim.o.grepprg
  local grepcmd

  -- Handle $* substitution in grepprg
  local substituted, count = grepprg:gsub("%$%*", args)
  if count == 0 then
    grepcmd = grepprg .. " " .. args
  else
    grepcmd = substituted
  end

  vim.api.nvim_exec_autocmds("QuickFixCmdPre", { pattern = "grep", modeline = false })

  local function callback(obj)
    local src = obj.code == 0 and obj.stdout or obj.stderr
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

local group = vim.api.nvim_create_augroup("grep#", { clear = true })
vim.api.nvim_create_autocmd("QuickFixCmdPost", {
  group = group,
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
  end
  return "gr"
end, { expr = true, silent = false })

vim.keymap.set("ca", "grep", function()
  if vim.fn.getcmdtype() == ":" and vim.fn.getcmdline() == "grep" then
    return "Grep"
  end
  return "grep"
end, { expr = true, silent = false })

vim.keymap.set("n", "<Space>/", ":Grep ", { silent = false })
vim.keymap.set("x", "<Space>/", 'y:<C-U>Grep <C-R>"', { silent = false })
vim.keymap.set("n", "<Space>*", ':Grep <C-R><C-W><CR>')
vim.keymap.set("x", "<Space>*", 'y:<C-U>Grep <C-R>"<CR>')
