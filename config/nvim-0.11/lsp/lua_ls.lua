return {
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  root_markers = { ".luarc.json" },
  settings = {
    Lua = {
      runtime = {
        version = "LuaJIT",
      },
      telemetry = {
        enable = false,
      },
      diagnostics = {
        globals = { "vim", "Snacks" },
      },
      codeLens = {
        enable = true,
      },
      workspace = {
        checkThirdParty = false,
        library = {
          [vim.fn.expand("$VIMRUNTIME/lua")] = true,
          [vim.fn.expand("$VIMRUNTIME/lua/vim/lsp")] = true,
          [vim.fn.stdpath("config") .. "/lua"] = true,
          [vim.fn.stdpath("data") .. "/lazy"] = true,
          ["${3rd}/luv/library"] = true,
        },
      },
      completion = {
        callSnippet = "Replace",
      },
      doc = {
        privateName = { "^_" },
      },
    },
  },
}
