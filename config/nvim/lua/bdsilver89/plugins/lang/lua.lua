local M = {}

-- local lua_ls_dev = {
--   options = {
--     library = {
--       enabled = true,
--       runtime = true,
--       types = true,
--       plugins = true,
--     },
--     path_strict = true,
--   },
-- }
--
-- function lua_ls_dev.types()
--   return lua_ls_dev.root("/types/" .. lua_ls_dev.version())
-- end
--
-- function lua_ls_dev.version()
--   return vim.version().prerelease and "nightly" or "stable"
-- end
--
-- function lua_ls_dev.root(dir)
--   local f = debug.getinfo(1, "S").source:sub(2)
--   return vim.uv.fs_realpath(vim.fn.fnamemodify(f, ":h:h:h") .. "/" .. (dir or ""))
-- end
--
-- local function lua_ls_libraries()
--   local ret = {}
--
--   if lua_ls_dev.options.library.types then
--     table.insert(ret, lua_ls_dev.types())
--   end
--
--   local function add(lib, filter)
--     for _, p in ipairs(vim.fn.expand(lib .. "/lua", false, true)) do
--       local plugin_name = vim.fn.fnamemodify(p, ":h:t")
--       p = vim.uv.fs_realpath(p)
--       if p and (not filter or filter[plugin_name]) then
--         if lua_ls_dev.options.path_strict then
--           table.insert(ret, p)
--         else
--           table.insert(ret, vim.fn.fnamemodify(p, ":h"))
--         end
--       end
--     end
--   end
--
--   if lua_ls_dev.options.library.runtime then
--     add("$VIMRUNTIME")
--   end
--
--   if lua_ls_dev.options.library.plugins then
--     for _, site in pairs(vim.split(vim.o.packpath, ",")) do
--       add(site .. "/pack/*/opt/*")
--       add(site .. "/pack/*/start/*")
--     end
--
--     for _, plugin in ipairs(require("lazy").plugins()) do
--       add(plugin.dir)
--     end
--   end
--
--   return ret
-- end
--
-- local function lua_ls_runtime_paths(settings)
--   if lua_ls_dev.options.path_strict then
--     return { "?.lua", "?/init.lua" }
--   end
--
--   settings = settings or {}
--   local runtime = settings.Lua and settings.Lua.runtime or {}
--   local meta = runtime.meta or "${version} ${language} ${encoding}"
--   meta = meta:gsub("%${version}", runtime.version or "LuaJIT")
--   meta = meta:gsub("%${language}", "en-us")
--   meta = meta:gsub("%${encoding}", runtime.fileEncoding or "utf8")
--
--   return {
--     -- paths for builtin libraries
--     ("meta/%s/?.lua"):format(meta),
--     ("meta/%s/?/init.lua"):format(meta),
--     -- paths for meta/third-party libraries
--     "library/?.lua",
--     "library/?/init.lua",
--     -- neovim lua files
--     "lua/?.lua",
--     "lua/?/init.lua",
--   }
-- end

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
