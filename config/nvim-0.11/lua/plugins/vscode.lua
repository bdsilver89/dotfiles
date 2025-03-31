if not vim.g.vscode then
  return {}
end

local enabled = {
  "lazy.nvim",
  "mini.nvim",
  "nvim-treesitter",
  "nvim-treesitter-textobjects",
}

local Config = require("lazy.core.config")
Config.options.checker.enabled = false
Config.options.change_detection.enabled = false
Config.options.defaults.cond = function(plugin)
  return vim.tbl_contains(enabled, plugin.name) or plugin.vscode
end

vim.api.nvim_create_autocmd("User", {
  pattern = "LazyVimKeymapsDefaults",
  callback = function()
    -- VSCode-specific keymaps for search and navigation
    vim.keymap.set("n", "<leader><space>", "<cmd>Find<cr>")
    vim.keymap.set("n", "<leader>/", [[<cmd>lua require('vscode').action('workbench.action.findInFiles')<cr>]])
    vim.keymap.set("n", "<leader>ss", [[<cmd>lua require('vscode').action('workbench.action.gotoSymbol')<cr>]])

    -- Keep undop/redo lists in sync with VSCode
    vim.keymap.set("n", "u", "<cmd>call VSCodeNotify('undo')<cr>")
    vim.keymap.set("n", "<c-r>", "<cmd>call VSCodeNotify('redo')<cr>")

    -- Navigate VSCode tabs like bufferline
    vim.keymap.set("n", "[b", "<cmd>call VSCodeNotify('workbench.action.previousEditor')<cr>")
    vim.keymap.set("n", "]b", "<cmd>call VSCodeNotify('workbench.action.nextEditor')<cr>")
  end,
})

return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { highlight = { enable = false } },
  },
}
