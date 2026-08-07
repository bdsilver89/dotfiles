---@type vim.lsp.Config
return {
  settings = {
    Lua = {
      workspace = {
        checkThirdParty = false,
        library = vim.api.nvim_get_runtime_file("", true),
      },
      diagnostics = {
        globals = { "vim" },
      },
      hint = { enable = true },
      telemetry = { enable = false },
      format = { enable = false },
    },
  },
}
