vim.pack.add({
  "https://github.com/esmuellert/codediff.nvim",
})

require("codediff").setup({})

-- Repos differ on main vs master, so resolve the remote's default branch.
local function base()
  local ref = vim.fn.systemlist({ "git", "symbolic-ref", "--short", "refs/remotes/origin/HEAD" })[1]
  return vim.v.shell_error == 0 and ref or "main"
end

vim.keymap.set("n", "<leader>gd", "<cmd>CodeDiff<cr>", { desc = "Diff working tree" })

vim.keymap.set("n", "<leader>gD", function()
  vim.cmd("CodeDiff " .. base() .. "...")
end, { desc = "Diff against default branch" })

vim.keymap.set("n", "<leader>gl", "<cmd>CodeDiff history<cr>", { desc = "File history" })
