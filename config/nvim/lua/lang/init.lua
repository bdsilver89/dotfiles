--- Per-language profile registry. A profile is `lua/lang/<name>.lua` returning
--- a table; all fields optional:
---
---   cond fun():boolean          skip profile when false
---   pack string[]               vim.pack specs
---   parsers string[]            treesitter parsers
---   servers table               name -> vim.lsp.config() settings
---   mason string[]              mason-tool-installer packages
---   formatters_by_ft table      ft -> conform formatters
---   linters_by_ft table         ft -> nvim-lint linters
---   dap table                   { adapters, configurations }
---   setup fun()                 runs after subsystems load
---
--- `mason` is not derived from `servers`, so a profile can enable a server whose
--- binary comes from the system toolchain rather than mason.
local M = {
  parsers = {},
  servers = {},
  formatters_by_ft = {},
  linters_by_ft = {},
  mason = {},
  dap = { adapters = {}, configurations = {} },
}

local hooks = {}

local function extend_unique(dst, src)
  for _, v in ipairs(src or {}) do
    if not vim.tbl_contains(dst, v) then
      table.insert(dst, v)
    end
  end
end

local function extend_map_of_lists(dst, src)
  for key, list in pairs(src or {}) do
    dst[key] = dst[key] or {}
    vim.list_extend(dst[key], list)
  end
end

local function load_profile(name)
  local ok, profile = pcall(require, "lang." .. name)
  if not ok then
    vim.notify(("lang: profile %q failed to load\n%s"):format(name, profile), vim.log.levels.ERROR)
    return nil
  end
  if type(profile) ~= "table" then
    vim.notify(("lang: profile %q must return a table"):format(name), vim.log.levels.ERROR)
    return nil
  end
  if profile.cond and not profile.cond() then
    return nil
  end
  return profile
end

function M.setup(names)
  local specs = {}

  for _, name in ipairs(names or {}) do
    local profile = load_profile(name)
    if profile then
      extend_unique(M.parsers, profile.parsers)
      extend_unique(M.mason, profile.mason)
      extend_map_of_lists(M.formatters_by_ft, profile.formatters_by_ft)
      extend_map_of_lists(M.linters_by_ft, profile.linters_by_ft)
      M.servers = vim.tbl_deep_extend("force", M.servers, profile.servers or {})

      if profile.dap then
        M.dap.adapters = vim.tbl_deep_extend("force", M.dap.adapters, profile.dap.adapters or {})
        extend_map_of_lists(M.dap.configurations, profile.dap.configurations)
      end

      extend_unique(specs, profile.pack or {})

      if profile.setup then
        table.insert(hooks, { name = name, fn = profile.setup })
      end
    end
  end

  if #specs > 0 then
    vim.pack.add(specs)
  end
end

function M.run_hooks()
  for _, hook in ipairs(hooks) do
    local ok, err = pcall(hook.fn)
    if not ok then
      vim.notify(("lang: setup hook %q failed\n%s"):format(hook.name, err), vim.log.levels.ERROR)
    end
  end
end

return M
