local add = require("pack").add
local on_plugin_update = require("pack").on_plugin_update

add({
  {
    src = "saghen/blink.lib",
    setup = false,
  },
  {
    src = "rafamadriz/friendly-snippets",
    setup = false,
  },
  {
    src = "L3MON4D3/LuaSnip",
    module_name = "luasnip",
    on_setup = function()
      require("luasnip.loaders.from_vscode").lazy_load()
    end,
  },
  {
    src = "saghen/blink.cmp",
    version = vim.version.range("1.*"),
    opts = {
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
        menu = {
          scrollbar = false,
          draw = {
            gap = 2,
            columns = {
              { "kind_icon", "kind", gap = 1 },
              { "label", "label_description", gap = 1 },
            },
          },
        },
      },
      fuzzy = { implementation = "prefer_rust" },
      snippets = { preset = "luasnip" },
      cmdline = { enabled = false },
      sources = {
        default = function()
          local sources = { "lsp", "buffer" }
          local ok, node = pcall(vim.treesitter.get_node)
          if ok and node then
            if not vim.tbl_contains({ "comment", "line_comment", "block_comment" }, node:type()) then
              table.insert(sources, "path")
            end
            if node:type() ~= "string" then
              table.insert(sources, "snippets")
            end
          end

          return sources
        end,
      },
    },
  },
})

on_plugin_update("LuaSnip", "make install_jsregexp")
