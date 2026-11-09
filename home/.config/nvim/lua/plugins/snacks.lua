require("snacks").setup({
  indent = { enabled = true },
  scroll = { enabled = false },
  picker = {
    enabled = true,
    sources = {
      files = { hidden = true },
      group = { hidden = true },
    },
  },
  notifier = { enabled = false },
  statuscolumn = { enabled = true },
  lazygit = {
    enabled = true,
    configure = true,
  },
  explorer = { enabled = true, replace_netrw = false },
  words = { enabled = true },
})

vim.keymap.set("n", "<leader>e", Snacks.picker.explorer)

vim.keymap.set("n", "<leader><space>", Snacks.picker.files)
vim.keymap.set("n", "<leader>/", Snacks.picker.grep)
vim.keymap.set("n", "<leader>,", Snacks.picker.buffers)
vim.keymap.set("n", "<leader>:", Snacks.picker.command_history)

vim.keymap.set("n", "<leader>gg", Snacks.lazygit.open)
vim.keymap.set("n", "<leader>gb", Snacks.picker.git_branches)
vim.keymap.set("n", "<leader>gl", Snacks.picker.git_log)
vim.keymap.set("n", "<leader>gL", Snacks.picker.git_log_line)
vim.keymap.set("n", "<leader>gs", Snacks.picker.git_status)
vim.keymap.set("n", "<leader>gS", Snacks.picker.git_stash)
vim.keymap.set("n", "<leader>gd", Snacks.picker.git_diff)
vim.keymap.set("n", "<leader>gf", Snacks.picker.git_log_file)
-- vim.keymap.set({ "n", "v" }, "<leader>gB", Snacks.gitbrowse)

vim.keymap.set("n", "<leader>gi", Snacks.picker.gh_issue)
vim.keymap.set("n", "<leader>gI", function()
  Snacks.picker.gh_issue({ state = "all" })
end)
vim.keymap.set("n", "<leader>gp", Snacks.picker.gh_pr)
vim.keymap.set("n", "<leader>gP", function()
  Snacks.picker.gh_pr({ state = "all" })
end)

Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
Snacks.toggle.option("background", { name = "Dark Background", off = "light", on = "dark" }):map("<leader>ub")
Snacks.toggle.diagnostics():map("<leader>ud")
Snacks.toggle.inlay_hints():map("<leader>uh")

vim.keymap.set("n", "<leader>bd", Snacks.bufdelete.delete, { desc = "Delete buffer" })

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("config_snacks_lspattach", { clear = true }),
  callback = function(ev)
    vim.keymap.set("n", "gd", Snacks.picker.lsp_definitions, { buf = ev.buf })
    vim.keymap.set("n", "gD", Snacks.picker.lsp_declarations, { buf = ev.buf })
    vim.keymap.set("n", "gri", Snacks.picker.lsp_implementations, { buf = ev.buf })
    vim.keymap.set("n", "grt", Snacks.picker.lsp_type_definitions, { buf = ev.buf })
    vim.keymap.set("n", "grr", Snacks.picker.lsp_references, { buf = ev.buf })
    vim.keymap.set("n", "gO", Snacks.picker.lsp_symbols, { buf = ev.buf })
    vim.keymap.set("n", "gW", Snacks.picker.lsp_workspace_symbols, { buf = ev.buf })

    vim.keymap.set({ "n", "t" }, "]]", function()
      Snacks.words.jump(vim.v.count1)
    end, { buf = ev.buf })
    vim.keymap.set({ "n", "t" }, "[[", function()
      Snacks.words.jump(-vim.v.count1)
    end, { buf = ev.buf })
  end,
})
