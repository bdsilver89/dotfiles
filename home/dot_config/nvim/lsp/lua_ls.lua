---@type vim.lsp.Config
return {
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  root_markers = {
    ".luarc.json",
    ".luarc.jsonc",
    ".luacheckrc",
    ".stylua.lua",
    "stylua.lua",
    "selene.toml",
    "selene.yml",
  },
  settings = {
    runtime = { version = "LuaJIT" },
    Lua = {
      workspace = {
        checkThirdParty = false,
        library = { vim.env.VIMRUNTIME },
      },
      codeLens = { enable = true },
      hint = { enable = true, semicolon = "Disable" },
      diagnostics = { globals = { "vim" } },
    },
  },
}
