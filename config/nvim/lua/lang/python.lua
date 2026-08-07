-- Pyright resolves imports against whatever `python` is on PATH and never looks
-- for a project venv, so uv/venv-only dependencies come back unresolved.
local function venv_python(root)
  local venv = vim.env.VIRTUAL_ENV or vim.env.CONDA_PREFIX

  if not venv and root then
    for _, dir in ipairs({ ".venv", "venv", ".env", "env" }) do
      if vim.fn.isdirectory(root .. "/" .. dir) == 1 then
        venv = root .. "/" .. dir
        break
      end
    end
  end
  if not venv then
    return nil
  end

  local exe = vim.fn.has("win32") == 1 and venv .. "/Scripts/python.exe" or venv .. "/bin/python"
  return vim.fn.executable(exe) == 1 and exe or nil
end

return {
  pack = {
    "https://github.com/mfussenegger/nvim-dap-python",
  },

  parsers = { "python", "toml" },

  servers = {
    pyright = {
      -- Mutated in place: the client captures `config.settings` by reference
      -- before before_init runs, so reassigning the field is discarded.
      before_init = function(_, config)
        local python = venv_python(config.root_dir)
        if python then
          config.settings.python = config.settings.python or {}
          config.settings.python.pythonPath = python
        end
      end,
    },
  },

  mason = {
    "pyright",
    "ruff",
    "debugpy",
  },

  formatters_by_ft = {
    python = { "ruff_organize_imports", "ruff_format" },
  },

  setup = function()
    local venv = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv"
    local python = vim.fn.has("win32") == 1 and venv .. "/Scripts/python.exe" or venv .. "/bin/python"

    -- Absent until mason finishes installing debugpy on a first run.
    if vim.fn.executable(python) == 1 then
      require("dap-python").setup(python)
    end
  end,
}
