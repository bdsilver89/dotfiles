---@class ConfigLanguageSpec
---@field treesitter? string|string[]
---@field lsp? string|string[]|fun():(string|string[]|nil)
---@field debugger? string|string[]
---@field formatter? string|string[]
---@field linter? string|string[]

local M = {}

---@type table<string, ConfigLanguageSpec>
M.configs = {
  bash = {
    treesitter = "bash",
    formatter = "shfmt",
  },
  cpp = {
    treesitter = { "cpp", "make", "ninja", "meson" },
    lsp = function()
      vim.lsp.enable("clangd")
    end,
    debugger = "codelldb",
  },
  c = {
    treesitter = { "c", "make", "ninja", "meson" },
    lsp = function()
      vim.lsp.enable("clangd")
    end,
    debugger = "codelldb",
  },
  cmake = {
    treesitter = "cmake",
    lsp = "neocmake",
    linter = "cmakelint",
    formatter = "cmakelang",
  },
  git = {
    treesitter = { "diff", "git_config", "gitcommit", "git_rebase", "gitignore", "gitattributes" },
  },
  go = {
    treesitter = { "go", "gomod", "gosum" },
    formatter = { "goimports", "gofumpt" },
  },
  javascript = {
    treesitter = { "http", "javascript", "typescript", "tsx" },
  },
  json = {
    treesitter = { "json", "json5" },
  },
  lua = {
    treesitter = { "lua", "luadoc", "luap" },
    formatter = "stylua",
    lsp = function()
      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
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
          },
        },
      })

      return "lua_ls"
    end,
  },
  python = {
    treesitter = { "python" },
    formatter = { "black" },
  },
  rust = {
    treesitter = { "ron", "rst", "rust" },
  },
  sql = {
    treesitter = "sql",
  },
  vim = {
    treesitter = { "printf", "regex", "query", "vim", "vimdoc" },
  },
  xml = {
    treesitter = { "xml" },
  },
  yaml = {
    treesitter = { "yaml" },
  },
}

local function coalesce(list, val)
  if type(val) == "string" then
    list[#list + 1] = val
  elseif type(val) == "table" then
    vim.list_extend(list, val)
  end
  return list
end

function M.treesitter()
  local ret = {}
  for _, cfg in pairs(M.configs) do
    coalesce(ret, cfg["treesitter"])
  end
  return ret
end

function M.formatter()
  local ret = {}
  for name, cfg in pairs(M.configs) do
    local f = cfg["formatter"]
    if type(f) == "string" then
      ret[name] = { f }
    elseif type(f) == "table" then
      ret[name] = f
    end
  end
  return ret
end

function M.lsp()
  local ret = {}
  for _, cfg in pairs(M.configs) do
    local f = cfg["lsp"]
    if type(f) == "function" then
      local v = f()
      coalesce(ret, v)
    else
      coalesce(ret, f)
    end
  end
  return ret
end

function M.tools()
  local ret = {}
  for _, cfg in pairs(M.configs) do
    coalesce(ret, cfg["debugger"])
    coalesce(ret, cfg["formatter"])
    coalesce(ret, cfg["linter"])
  end
  return ret
end

return M
