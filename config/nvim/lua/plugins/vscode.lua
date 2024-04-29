if not vim.g.vscode then
  return {}
end

local enabled = {
  "lazy.nvim",
  "Comment.nvim",
  "mini.ai",
  "mini.pairs",
  "mini.surround",
  "nvim-treesitter",
  "nvim-treesitter-textobjects",
  "nvim-treesitter-commentstring",
}

-- change lazy.nvim configuration to disable checker and change detection
-- limit plugins to allowed subset
local Config = require("lazy.core.config")
Config.options.checker.enabled = false
Config.options.change_detection.enabled = false
Config.options.defaults.cond = function(plugin)
  return vim.tbl_contains(enabled, plugin.name) or plugin.vscode
end

-- add some vscode-specifig keymaps
vim.api.nvim_create_autocmd("User", {
  pattern = "ConfigKeymaps",
  callback = function()
    vim.keymap.set("n", "<leader><space>", "<cmd>Find<cr>")
    vim.keymap.set("n", "<leader>/", "[[<cmd>call VSCodeNotify('workbench.action.findInFiles')<cr>]]")
    vim.keymap.set("n", "<leader>ss", "[[<cmd>call VSCodeNotify('workbench.action.gotoSymbol')<cr>]]")
  end,
})

-- any plugin option changes here
return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      highlight = { enable = false },
    },
  },
}
