if not vim.g.vscode then
  return {}
end

local enabled = {
  "mini.nvim",
  "nvim-treesitter",
}

local Config = require("lazy.core.config")
Config.options.checker.enabled = false
Config.options.change_detection.enabled = false
Config.options.defaults.cond = function(plugin)
  return vim.tbl_contains(enabled, plugin.name) or plugin.vscode
end

vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  callback = function()
    -- vscode keymaps for search/navigation
    vim.keymap.set("n", "<leader><space>", "<cmd>Find<cr>")
    vim.keymap.set("n", "<leader>/", [[<cmd>lua require('vscode').action('workbench.action.findInFiles')<cr>]])
    vim.keymap.set("n", "<leader>ss", [[<cmd>lua require('vscode').action('workbench.action.gotoSymbol')<cr>]])

    -- undo/redo history in sync with vscode
    vim.keymap.set("n", "u", "<cmd>call VSCodeNotify('undo')<cr>")
    vim.keymap.set("n", "<c-r>", "<cmd>call VSCodeNotify('redo')<cr>")

    -- navigate vscode tabs like nvim buffers
    vim.keymap.set("n", "[b", "<cmd>call VSCodeNotify('workbench.action.previousEditor')<cr>")
    vim.keymap.set("n", "]b", "<cmd>call VSCodeNotify('workbench.action.nextEditor')<cr>")
  end,
})

return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      highlight = { enable = false },
    },
  },
}
