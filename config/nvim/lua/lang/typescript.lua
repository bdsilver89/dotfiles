local prettier = { "prettierd", "prettier", stop_after_first = true }

return {
  parsers = { "javascript", "typescript", "tsx", "jsdoc", "html", "css" },

  servers = {
    vtsls = {},
    eslint = {},
  },

  mason = { "vtsls", "eslint", "prettierd", "js-debug-adapter" },

  formatters_by_ft = {
    javascript = prettier,
    javascriptreact = prettier,
    typescript = prettier,
    typescriptreact = prettier,
    html = prettier,
    css = prettier,
  },

  dap = {
    adapters = {
      ["pwa-node"] = {
        type = "server",
        host = "localhost",
        port = "${port}",
        executable = {
          command = "js-debug-adapter",
          args = { "${port}" },
        },
      },
    },
    configurations = {
      javascript = {
        {
          type = "pwa-node",
          request = "launch",
          name = "Launch file",
          program = "${file}",
          cwd = "${workspaceFolder}",
        },
      },
      typescript = {
        {
          type = "pwa-node",
          request = "launch",
          name = "Launch file",
          program = "${file}",
          cwd = "${workspaceFolder}",
          runtimeExecutable = "tsx",
        },
      },
    },
  },
}
