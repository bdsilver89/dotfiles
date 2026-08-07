vim.pack.add({
  "https://github.com/saghen/blink.lib",
  "https://github.com/saghen/blink.cmp",
  "https://github.com/L3MON4D3/LuaSnip",
  "https://github.com/rafamadriz/friendly-snippets",
})

require("luasnip.loaders.from_vscode").lazy_load()

require("blink.cmp").setup({
  snippets = { preset = "luasnip" },
  keymap = {
    preset = "default",
    ["<tab>"] = { "accept", "fallback" },
    ["<cr>"] = { "accept", "fallback" },
    ["<s-tab>"] = { "show" },
  },
  completion = {
    menu = {
      draw = {
        treesitter = { "lsp" },
        columns = { { "kind_icon", "label", "label_description", gap = 1 }, { "kind" } },
      },
    },
    documentation = {
      auto_show = true,
      auto_show_delay_ms = 200,
    },
    ghost_text = {
      enabled = true,
    },
  },
  signature = { enabled = true },
  fuzzy = { implementation = "lua" },
  sources = {
    default = { "lsp", "path", "snippets", "buffer" },
    per_filetype = {
      sql = { "lsp", "snippets", "buffer" },
    },
    providers = {
      lsp = { score_offset = 90 },
    },
  },
})

vim.api.nvim_create_autocmd("PackChanged", {
  group = vim.api.nvim_create_augroup("config_blink", { clear = true }),
  callback = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    if name == "blink.cmp" and (kind == "install" or kind == "update") then
      vim.notify("Building build.cmp...")
      vim.system({ "cargo", "build", "--release" }, { cwd = ev.data.path }):wait()
      local cmp = require("blink.cmp")
      cmp.build():pwait()
    end
  end,
})
