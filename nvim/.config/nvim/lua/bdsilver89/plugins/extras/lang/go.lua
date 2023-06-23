local function get_delve()
  local mason_registry = require("mason-registry")
  local dlv = mason_registry.get_package("delve")
  return dlv:get_install_path() .. "/dlv"
end

if not require("bdsilver89.config.lang").langs.go then
  return {}
end

return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, { "go", "gomod", "gowork" })
    end,
  },
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, { "delve" })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        gopls = {},
      },
    },
  },
  {
    "mfussenegger/nvim-dap",
    opts = {
      setup = {
        delve = function()
          local dap = require("dap")

          dap.adapters.delve = {
            type = "server",
            port = "${port}",
            executable = {
              command = get_delve(),
              args = { "dap", "-l", "127.0.0.1:${port}" },
            },
          }

          dap.configurations.go = {
            {
              type = "delve",
              name = "Debug",
              request = "launch",
              program = "${file}",
            },
            {
              type = "delve",
              name = "Debug test",
              request = "launch",
              mode = "test",
              program = "${file}",
            },
            {
              type = "delve",
              name = "Debug test (go.mod)",
              request = "launch",
              mode = "test",
              program = "./${relativeFileDirname}",
            },
          }

          --     -- dap.adapters.go = {
          --     --   type = "server",
          --     --   port = "${port}",
          --     --   -- executable = {
          --     --   --   command = codelldb_path,
          --     --   --   args = { "--port", "${port}" },
          --     --   -- },
          --     -- }
          --
          --     dap.adapters.go = function(callback, config)
          --       local stdout = vim.loop.new_pipe(false)
          --       local handle
          --       local pid_or_err
          --       local port = 38697
          --       local opts = {
          --         stdio = { nil, stdout },
          --         args = { "dap", "-l", "127.0.0.1:" .. port },
          --         detatched = true,
          --       }
          --       handle, pid_or_err = vim.loop.spawn("dlv", opts, function(code)
          --         stdout:close()
          --         handle:close()
          --         if code ~= 0 then
          --           print("dlv exited with code ", code)
          --         end
          --       end)
          --       assert(handle, "Error running dlv: " .. tostring(pid_or_err))
          --       stdout:read_start(function(err, chunk)
          --         assert(not err, err)
          --         if chunk then
          --           vim.schedule(function()
          --             require("dap.repl").append(chunk)
          --           end)
          --         end
          --       end)
          --
          --       vim.defer_fn(function()
          --         callback({ type = "server", host = "127.0.0.1", port = port })
          --       end, 100)
          --     end
          --
          --     dap.configurations.go = {
          --       {
          --         type = "go",
          --         name = "Debug",
          --         request = "launch",
          --         program = "${file}",
          --       },
          --     }
        end,
      },
    },
  },
}
