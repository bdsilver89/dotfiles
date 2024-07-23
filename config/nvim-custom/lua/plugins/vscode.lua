if not vim.g.vscode then
  return {}
end

local enabled = {
  "flash.nvim",
  "vim-illuminate",
  "lazy.nvim",
  "nvim-autopairs",
  "nvim-treesitter",
  "nvim-treesitter-textobjects",
}

local Config = require("lazy.core.config")
Config.options.checker.enabled = false
Config.options.change_detection.enabled = false
Config.options.defaults.cond = function(plugin)
  return vim.tbl_contains(enabled, plugin.name) or plugin.vscode
end

-- stylua: ignore start
vim.keymap.set("n", "<leader><leader>", "<cmd>Find<cr>")
vim.keymap.set("n", "<leader>/", function() require("vscode-neovim").call("workbench.action.findInFiles") end)
vim.keymap.set("n", "<leader>ss", function() require("vscode-neovim").call("workbench.action.gotoSymbol") end)
-- stylua: ignore end

vim.keymap.set("n", "<c-h>", "<c-w>h", { desc = "Go to left window", remap = true })
vim.keymap.set("n", "<c-j>", "<c-w>j", { desc = "Go to lower window", remap = true })
vim.keymap.set("n", "<c-k>", "<c-w>k", { desc = "Go to upper window", remap = true })
vim.keymap.set("n", "<c-l>", "<c-w>l", { desc = "Go to right window", remap = true })

vim.notify = require("vscode-neovim").notify

return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      highlight = { enable = false },
    },
  },
}
