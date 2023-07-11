if not require("config").pde.cpp then
  return {}
end

local function get_codelldb()
  local mason_registry = require("mason-registry")
  local codelldb = mason_registry.get_package("codelldb")
  local extension_path = codelldb:get_install_path() .. "/extension/"
  local codelldb_path = extension_path .. "adapter/codelldb"
  local liblldb_path = extension_path .. "lldb/lib/liblldb.so"
  return codelldb_path, liblldb_path
end

local function get_cpptools()
  local mason_registry = require("mason-registry")
  local codelldb = mason_registry.get_package("cpptools")
  local extension_path = codelldb:get_install_path() .. "/extension/"
  local cpptools_path = extension_path .. "debugAdapters/bin/OpenDebugAD7"
  return cpptools_path
end

return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, { "c", "cpp", "cmake" })
    end,
  },
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, { "codelldb", "cpptools" })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "p00f/clangd_extensions.nvim",
    },
    opts = {
      servers = {
        clangd = {}
      },
      setup = {
        clangd = function(_, opts)
          require("clangd_extensions").setup({
            server = opts.server,
            extensions = opts.extensions
          })
          return true
        end,
      }
    }
  },
  {
    "nvim-cmp",
    opts = function(_, opts)
      table.insert(opts.sorting.comparators, 1, require("clangd_extensions.cmp_scores"))
    end,
  },
  {
    "mfussenegger/nvim-dap",
    opts = {
      setup = function()
        local dap = require("dap")

        local codelldb_path = get_codelldb()
        local cpptools_path = get_cpptools()

        dap.adapters.codelldb = {
          type = "server",
          host = "localhost",
          port = "${port}",
          executable = {
            command = codelldb_path,
            args = { "--port", "${port}" },
            -- for windows:
            -- detached = false
          },
        }

        dap.adapters.cpptools = {
          id = "cppdbg",
          type = "executable",
          command = cpptools_path,
        }

        dap.configurations.cpp = {
          {
            name = "Launch file (codelldb)",
            type = "codelldb",
            request = "launch",
            program = function()
              return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
            end,
            cwd =  "${workspaceFolder}",
            stopOnEntry = false,
          },
          {
            name = "Launch file (cppdbg)",
            type = "cppdbg",
            request = "launch",
            program = function()
              return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
            end,
            cwd =  "${workspaceFolder}",
            stopOnEntry = false,
          },
        }

        dap.configurations.c = dap.configurations.cpp
        dap.configurations.rust = dap.configurations.cpp
      end,
    },
  },
  {
    "nvim-neotest/neotest",
    dependencies = {
      {
        "alfaix/neotest-gtest",
        opts = {},
      },
    },
    opts = function(_, opts)
      vim.list_extend(opts.adapters, {
        require("neotest-gtest")
      })
    end,
  }
}
