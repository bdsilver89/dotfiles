vim.pack.add({
  "https://github.com/saghen/blink.lib",
  "https://github.com/saghen/blink.cmp",
  "https://github.com/rafamadriz/friendly-snippets",
})

require("blink.cmp").setup({
  snippets = { preset = "default" },
  keymap = {
    preset = "default",
    ["<tab>"] = { "accept", "fallback" },
    ["<cr>"] = { "accept", "fallback" },
    ["<s-tab>"] = { "show" },
  },
  appearance = {
    nerd_font_variant = "mono",
  },
  completion = {
    documentation = {
      auto_show = true,
      auto_show_delay_ms = 500,
    },
  },
  fuzzy = { implementation = "prefer_rust" },
  signature = { enabled = true },
  sources = {
    default = { "lsp", "path", "snippets", "buffer" },
    per_filetype = {
      sql = { "lsp", "snippets", "buffer" },
    },
  },
})

vim.api.nvim_create_autocmd("PackChanged", {
  group = vim.api.nvim_create_augroup("config_packchangedblink", { clear = true }),
  callback = function(ev)
    local name = ev.data.spec.name
    local kind = ev.data.kind
    if kind ~= "install" and kind ~= "update" then
      return
    end

    if name == "blink.cmp" then
      local cmp = require("blink.cmp")
      cmp.build():pwait()
    end
  end,
})
