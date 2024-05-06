local M = {}

function M.lsp_config()
  if not vim.g.enable_lua_support then
    return {}
  end

  return {
    lua_ls = {
      settings = {
        Lua = {
          -- runtime = {
          --   version = "LuaJIT",
          --   path = lua_ls_runtime_paths(),
          --   pathStrict = lua_ls_dev.options.path_strict,
          -- },
          workspace = {
            checkThirdParty = false,
            -- library = lua_ls_libraries(),
          },
          codeLens = {
            enable = true,
          },
          completion = {
            callSnippet = "Replace",
          },
        },
      },
    },
  }
end

return M
