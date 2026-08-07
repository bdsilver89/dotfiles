return {
  cond = function()
    return vim.fn.executable("rust-analyzer") == 1
  end,

  parsers = { "rust", "toml" },

  servers = {
    rust_analyzer = {
      settings = {
        ["rust-analyzer"] = {
          cargo = { allFeatures = true },
          checkOnSave = true,
          check = { command = "clippy" },
        },
      },
    },
  },

  mason = { "codelldb" },

  formatters_by_ft = {
    rust = { "rustfmt" },
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
      rust = {
        {
          name = "Launch file",
          type = "codelldb",
          request = "launch",
          program = function()
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/target/debug/", "file")
          end,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
        },
      },
    },
  },
}
