if not vim.g.vscode then
  return {}
end

local enabled_plugins = {
  "Comment.nvim",
  "lazy.nvim",
  "nvim-treesitter",
  "nvim-ts-context-commentstring",
}

local Config = require("lazy.core.config")
Config.options.checker.enabled = false
Config.options.change_detection.enabled = false
Config.options.defaults.cond = function(plugin)
  return vim.tbl_contains(enabled_plugins, plugin.name) or plugin.vscode
end

-- change vim.notify to vscode notifications
vim.api.nvim_create_autocmd("User", {
  pattern = "ConfigOptions",
  callback = function()
    local vscode = require("vscode-neovim")
    vim.notify = vscode.notify
  end,
})

-- add vscode specific keymaps
vim.api.nvim_create_autocmd("User", {
  pattern = "ConfigKeymaps",
  callback = function()
    vim.keymap.set("n", "<leader><leader>", "<cmd>Find<cr>")
    vim.keymap.set("n", "<leader>/", function() require("vscode-neovim").call("workbench.action.findInFiles") end)
    vim.keymap.set("n", "<leader>ss", function() require("vscode-neovim").call("workbench.action.gotoSymbol") end)
  end,
})

return {}
