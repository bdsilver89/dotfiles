---@class LangSpec
---@field filetypes string[]
---@field parsers string[]
---@field lsp_servers? (string|LspSpec)[]
---@field linters? (string|LinterSpec)[]
---@field formatters? (string|FormatterSpec)[]
---@field dap? string[]
---@field test? string[]

---@class LspSpec
---@field [1] string
---@field enabled? fun(): boolean

---@class LinterSpec
---@field [1] string
---@field opts? table
---@field command? string
---@field mason? MasonSpec

---@class FormatterSpec
---@field [1] string
---@field opts? table
---@field command? string
---@field mason? MasonSpec

---@field MasonSpec
---@field enabled? boolean
---@field package string

---@type table<string, LangSpec>
return {
  -- bash = {
  --   filetypes = { "sh" },
  --   parsers = { "bash" },
  --   lsp_servers = { "bashls" },
  --   formatters = {
  --     "shellcheck",
  --     { "shfmt", opts = { prepend_args = { "-i", "2", "-ci", "-bn", "-sr" } } },
  --   },
  -- },

-- TODO: more

  lua = {
    filetypes = { "lua" },
    parsers = { "lua" },
    lsp_servers = { "lua_ls" },
    formatters = { "stylua" },
  },
}
