vim.pack.add({
  { src = "https://github.com/saghen/blink.cmp", version = vim.version.range("^1") },
}, { load = false })

vim.api.nvim_create_autocmd("InsertEnter", {
  once = true,
  callback = function()
    vim.cmd.packadd("blink.cmp")
    require("blink.cmp").setup({
      keymap = {
        ["<cr>"] = { "accept", "fallback" },
        ["<c-\\>"] = { "hide", "fallback" },
        ["<c-n>"] = { "select_next", "show" },
        ["<tab>"] = { "select_next", "snippet_forward", "fallback" },
        ["<c-p>"] = { "select_prev" },
        ["<s-tab>"] = { "select_prev", "snippet_backward", "fallback" },
        ["<c-b>"] = { "scroll_documentation_up", "fallback" },
        ["<c-f>"] = { "scroll_documentation_down", "fallback" },
      },
      completion = {
        documentation = { auto_show = true },
      },
      fuzzy = { implementation = "prefer_rust" },
    })
  end,
})
