vim.pack.add({
  "https://github.com/folke/snacks.nvim",
})

require("snacks").setup({
  animate = { enabled = false },
  bigfile = { enabled = true },
  dashboard = { enabled = false },
  explorer = { enabled = true, replace_netrw = false },
  indent = { enabled = true },
  -- input = { enabled = true },
  notifier = { enabled = false },
  picker = {},
  quickfile = { enabled = true },
  statuscolumn = { enabled = true },
})

vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    vim.schedule(function()
      Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
      Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
      Snacks.toggle.diagnostics():map("<leader>ud")
      Snacks.toggle.line_number():map("<leader>ul")
      Snacks.toggle.option("background", { off = "light", on = "dark", name = "Dark Background" }):map("<leader>ub")
    end)
  end,
})

-- stylua: ignore start
vim.keymap.set("n", "<leader>e", function() Snacks.explorer() end, { desc = "File explorer" })
vim.keymap.set("n", "<leader><space>", function() Snacks.picker.smart() end, { desc = "Find files" })
vim.keymap.set("n", "<leader>/", function() Snacks.picker.grep() end, { desc = "Grep" })
vim.keymap.set("n", "<leader>:", function() Snacks.picker.command_history() end, { desc = "History" })
vim.keymap.set("n", "<leader>,", function() Snacks.picker.buffers() end, { desc = "Buffers" })

vim.keymap.set("n", "<leader>gb", function() Snacks.picker.git_branches() end, { desc = "Git branches" })
vim.keymap.set("n", "<leader>gl", function() Snacks.picker.git_log() end, { desc = "Git log" })
vim.keymap.set("n", "<leader>gL", function() Snacks.picker.git_log_line() end, { desc = "Git log line" })
vim.keymap.set("n", "<leader>gs", function() Snacks.picker.git_status() end, { desc = "Git status" })
vim.keymap.set("n", "<leader>gS", function() Snacks.picker.git_stash() end, { desc = "Git stash" })
vim.keymap.set("n", "<leader>gp", function() Snacks.picker.git_diff() end, { desc = "Git diff" })
vim.keymap.set("n", "<leader>gP", function() Snacks.picker.git_diff({ base = "origin" }) end, { desc = "Git diff origin" })
vim.keymap.set("n", "<leader>gf", function() Snacks.picker.git_log_file() end, { desc = "Git log file" })
vim.keymap.set("n", "<leader>gg", function() Snacks.picker.git_log_file() end, { desc = "Git log file" })
vim.keymap.set("n", "<leader>gB", function() Snacks.gitbrowse() end, { desc = "Git browse (open)" })
vim.keymap.set("n", "<leader>gY", function() Snacks.gitbrowse({ open = function(url) vim.fn.setreg("+", url) end, notify = false }) end, { desc = "Git browse (copy)" })

if vim.fn.executable("lazygit") == 1 then
  vim.keymap.set("n", "<leader>gg", function() Snacks.lazygit() end, { desc = "Lazygit" })
end

vim.keymap.set("n", "<c-:>", function() Snacks.terminal(nil, { cwd = vim.fn.getcwd() }) end, { desc = "Toggle terminal (root)" })
vim.keymap.set("n", "<c-/>", function() Snacks.terminal(nil) end, { desc = "Toggle terminal" })
vim.keymap.set("n", "<c-_>", function() Snacks.terminal(nil, { cwd = vim.fn.getcwd() }) end, { desc = "which_key_ignore" })

-- vim.keymap.set("n", "]]", function() Snacks.words.jump(vim.v.count1) end, { desc = "Next reference" })
-- vim.keymap.set("n", "[[", function() Snacks.words.jump(-vim.v.count1) end, { desc = "Prev reference" })

-- stylua: ignore end
