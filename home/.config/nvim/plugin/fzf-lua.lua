vim.pack.add({
  "https://github.com/ibhagwan/fzf-lua",
})

require("fzf-lua").setup({
  register_ui_select = true, 
  keymap = {
    fzf = {
      ["ctrl-q"] = "select-all+accept",
    },
  },
})

vim.keymap.set("n", "<leader>sb", "<cmd>FzfLua buffers<cr>")
vim.keymap.set("n", "<leader>sf", "<cmd>FzfLua files<cr>")
vim.keymap.set("n", "<leader>sg", "<cmd>FzfLua live_grep<cr>")
vim.keymap.set("n", "<leader>sh", "<cmd>FzfLua command_history<cr>")
vim.keymap.set("n", "<leader>sH", "<cmd>FzfLua search_history<cr>")
vim.keymap.set("n", "<leader>sw", "<cmd>FzfLua grep_cword<cr>")
vim.keymap.set("x", "<leader>sw", "<cmd>FzfLua grep_visual<cr>")

vim.keymap.set("n", "<leader>gb", "<cmd>FzfLua git_branches<cr>")
vim.keymap.set("n", "<leader>gd", "<cmd>FzfLua git_diff<cr>")
vim.keymap.set("n", "<leader>gf", "<cmd>FzfLua git_bcommits<cr>")
vim.keymap.set("n", "<leader>gl", "<cmd>FzfLua git_commits<cr>")
vim.keymap.set("n", "<leader>gs", "<cmd>FzfLua git_status<cr>")
vim.keymap.set("n", "<leader>gS", "<cmd>FzfLua git_stash<cr>")
vim.keymap.set("n", "<leader>gw", "<cmd>FzfLua git_worktrees<cr>")
