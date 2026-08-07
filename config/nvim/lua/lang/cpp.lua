return {
  cond = function()
    return vim.fn.executable("clangd") == 1
  end,

  parsers = { "c", "cpp" },

  servers = {
    clangd = {},
  },

  mason = { "codelldb" },

  formatters_by_ft = {
    c = { "clang-format" },
    cpp = { "clang-format" },
  },

  dap = {
    adapters = {
      codelldb = {
        type = "server",
        port = "${port}",
        executable = {
          command = "codelldb",
          args = { "--port", "${port}" },
        },
      },
    },
    configurations = {
      c = {
        {
          name = "Launch file",
          type = "codelldb",
          request = "launch",
          program = function()
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
          end,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
        },
      },
      cpp = {
        {
          name = "Launch file",
          type = "codelldb",
          request = "launch",
          program = function()
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
          end,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
        },
      },
    },
  },
}
