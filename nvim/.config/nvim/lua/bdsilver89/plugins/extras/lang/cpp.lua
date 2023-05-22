local function get_codelldb()
  local mason_registry = require("mason-registry")
  local codelldb = mason_registry.get_package("codelldb")
  local extension_path = codelldb:get_install_path() .. "/extension/"
  local codelldb_path = extension_path .. "adapter/codelldb"
  local liblldb_path = extension_path .. "lldb/lib/liblldb.so"
  return codelldb_path, liblldb_path
end

return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, { "cpp", "c", "cmake" })
    end,
  },
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, { "codelldb" })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        clangd = {},
        cmake = {},
      },
    },
  },
  {
    "mfussenegger/nvim-dap",
    opts = {
      setup = {
        codelldb = function()
          local codelldb_path, liblldb_path = get_codelldb()
          local dap = require("dap")

          dap.adapters.codelldb = {
            type = "server",
            port = "${port}",
            executable = {
              command = codelldb_path,
              args = { "--port", "${port}" },
            },
            showDissasembly = "never",
          }
          dap.configurations.cpp = {
            {
              name = "Launch",
              type = "codelldb",
              request = "launch",
              program = function()
                return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
              end,
              -- args = function()
              --   local val = vim.fn.input("Args: ")
              --   if val ~= "" then
              --     return val
              --   end
              --   return nil
              -- end,
              args = {},
              cwd = "${workspaceFolder}",
              stopOnEntry = true,
            },
          }

          dap.configurations.c = dap.configurations.cpp
          dap.configurations.rust = dap.configurations.cpp
        end,
      },
    },
  },
}
