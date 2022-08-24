local status, trouble = pcall(require, "trouble")
if (not status) then return end

trouble.setup({
  position = "bottom",
  height = 10,
  width = 50,
  icons = true,
  mode = "document_diagnostics",
  fold_open = "",
  fold_closed = "",
  action_keys = {
    close = "q",
    cancel = "<esc>",
    refresh = "r",
    jump = { "<cr>", "<tab>" },
    open_split = { "ss" },
    open_vsplit = { "sv" },
    jump_close = { "o" },
    toggle_mode = "m",
    toggle_preview = "P",
    hover = "K",
    preview = "p",
    close_folds = { "zM", "zm" },
    open_folds = { "zR", "zr" },
    toggle_folds = { "zA", "za" },
    previous = "l",
    next = "j",
  },
  indent_lines = true,
  auto_open = false,
  auto_close = false,
  auto_preview = true,
  auto_fold = false,
  signs = {
    error = "",
    warning = "",
    hint = "",
    information = "",
    other = "﫠",
  },
  use_lsp_diagnostic_signs = false,
})

vim.keymap.set("n", "gt", ":TroubleToggle<CR>", { silent = true})
vim.keymap.set("n", "gR", ":TroubleToggle lsp_references<CR>", { silent = true})
vim.keymap.set("n", "<leader>cd", ":TroubleToggle document_diagnostics<CR>", { silent = true})
vim.keymap.set("n", "<leader>cw", ":TroubleToggle workspace_diagnostics<CR>", { silent = true})
vim.keymap.set("n", "<leader>cq", ":TroubleToggle quickfix<CR>", { silent = true})
vim.keymap.set("n", "<leader>cl", ":TroubleToggle loclist<CR>", { silent = true})
