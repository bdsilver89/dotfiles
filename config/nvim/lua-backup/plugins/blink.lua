vim.pack.add({
  "https://github.com/saghen/blink.cmp",
  "https://github.com/saghen/blink.lib",
  "https://github.com/L3MON4D3/LuaSnip",
  "https://github.com/rafamadriz/friendly-snippets",
})

vim.api.nvim_create_autocmd("InsertEnter", {
  group = vim.api.nvim_create_augroup("config_blinkload", { clear = true }),
  once = true,
  callback = function()
    require("blink.cmp").setup({
      completion = {
        documentation = {
          auto_show = true,
        },
        ghost_text = {
          enabled = true,
        },
      },
      keymap = {
        preset = "enter",
      },
      fuzzy = {
        implementation = "lua",
      },
    })
  end
})
