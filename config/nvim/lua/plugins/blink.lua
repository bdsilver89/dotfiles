local blink_main = false
local blink_lua = false

return {
  "saghen/blink.cmp",
  event = "InsertEnter",
  version = not blink_main and "*",
  build = blink_main and "cargo --build release",
  dependencies = "LuaSnip",
  opts = {
    keymap = {
      ["<CR>"] = { "accept", "fallback" },
      ["<C-\\>"] = { "hide", "fallback" },
      ["<C-n>"] = { "select_next", "show" },
      ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
      ["<C-p>"] = { "select_prev" },
      ["<C-b>"] = { "scroll_documentation_up", "fallback" },
      ["<C-f>"] = { "scroll_documentation_down", "fallback" },
    },
    completion = {
      list = {
        selection = { preselect = false, auto_insert = true },
        max_items = 10,
      },
      documentation = { auto_show = true },
    },
    fuzzy = { implementation = blink_lua and "lua" or "prefer_rust" },
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
  config = function(_, opts)
    require("blink.cmp").setup(opts)

    vim.lsp.config("*", {
      capabilities = require("blink.cmp").get_lsp_capabilities(nil, true),
    })
  end,
}
