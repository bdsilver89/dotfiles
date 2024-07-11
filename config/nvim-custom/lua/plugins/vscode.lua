if not vim.g.vscode then
  return {}
end

local enabled = {
  "lazy.nvim",
  "nvim-treesitter",
  "nvim-treesitter-textobjects",
}

local Config = require("lazy.core.config")
Config.options.checker.enabled = false
Config.options.change_detection.enabled = false
Config.options.defaults.cond = function(plugin)
  return vim.tbl_contains(enabled, plugin.name) or plugin.vscode
end

-- change vim.notify to vscode notifications
-- change vim.notify to vscode notifications
vim.api.nvim_create_autocmd("User", {
  pattern = "ConfigOptions",
  callback = function()
    local vscode = require("vscode-neovim")
    vim.notify = vscode.notify
  end,
})
vim.api.nvim_create_autocmd("User", {
  pattern = "ConfigOptions",
  callback = function()
    local vscode = require("vscode-neovim")
    vim.notify = vscode.notify
  end,
})

-- Add some vscode specific keymaps
vim.api.nvim_create_autocmd("User", {
  pattern = "LazyVimKeymaps",
  callback = function()
    vim.keymap.set("n", "<leader><space>", "<cmd>Find<cr>")
    vim.keymap.set("n", "<leader>/", [[<cmd>call VSCodeNotify('workbench.action.findInFiles')<cr>]])
    vim.keymap.set("n", "<leader>ss", [[<cmd>call VSCodeNotify('workbench.action.gotoSymbol')<cr>]])
  end,
})

return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { highlight = { enable = false } },
  },
}
