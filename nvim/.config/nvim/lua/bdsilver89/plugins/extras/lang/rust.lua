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
      vim.list_extend(opts.ensure_installed, { "rust" })
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
      "simrat39/rust-tools.nvim",
      "rust-lang/rust.vim",
    },
    opts = {
      servers = {
        rust_analyzer = {
          settings = {
            ["rust_analyzer"] = {
              cargo = {
                allFeatures = true,
              },
              checkOnSave = {
                command = "cargo clippy",
                extraArgs = { "--no-deps" },
              },
            },
          },
        },
      },
      setup = {
        rust_analyzer = function(_, opts)
          local codelldb_path, liblldb_path = get_codelldb()
          local lsp_utils = require("bdsilver89.plugins.lsp.utils")
          lsp_utils.on_attach(function(client, buffer)
            if client.name == "rust_analyzer" then
              vim.keymap.set("n", "<leader>cR", "<cmd>RustRunnables<cr>", { buffer = buffer, desc = "Runnables" })
              vim.keymap.set("n", "<leader>cl", function()
                vim.lsp.codelens.run()
              end, { buffer = buffer, desc = "Codelens" })
            end
          end)

          require("rust-tools").setup({
            tools = {
              hover_actions = { border = "solid" },
              on_initialized = function()
                vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter", "CursorHold", "InsertLeave" }, {
                  pattern = "*.rs",
                  callback = function()
                    vim.lsp.codelens.refresh()
                  end,
                })
              end,
            },
            server = opts,
            dap = {
              adapter = require("rust-tools.dap").get_codelldb_adapter(codelldb_path, liblldb_path),
            },
          })
          return true
        end,
      },
    },
  },
  {
    "mfussenegger/nvim-dap",
    opts = {
      setup = {
        codelldb = function()
          local codelldb_path = get_codelldb()
          local dap = require("dap")
          dap.adapters.codelldb = {
            type = "server",
            port = "${port}",
            executable = {
              command = codelldb_path,
              args = { "--port", "${port}" },
              -- On windows you may have to uncomment this:
              -- detached = false,
            },
          }

          vim.list_extend(dap.configurations.cpp, {
            name = "Launch file (codelldb)",
            type = "codelldb",
            request = "launch",
            program = function()
              return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
            end,
            cwd = "${workspaceFolder}",
            stopOnEntry = true,
          })

          dap.configurations.c = dap.configurations.cpp
          dap.configurations.rust = dap.configurations.cpp
        end,
        cpptools = function()
          local cpptools_path = get_cpptools()
          local dap = require("dap")

          dap.adapters.cpptools = {
            id = "cppdbg",
            type = "executable",
            command = cpptools_path,
          }

          vim.list_extend(dap.configurations.cpp, {
            name = "Launch file (cppdbg)",
            type = "cppdbg",
            request = "launch",
            program = function()
              return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
            end,
            cwd = "${workspaceFolder}",

            stopOnEntry = true,
          })

          dap.configurations.c = dap.configurations.cpp
          dap.configurations.rust = dap.configurations.cpp
        end,
      },
    },
  },
  {
    "danymat/neogen",
    opts = {
      languages = {
        rust = {
          template = {
            annotation_convention = "rustdoc",
          },
        },
      },
    },
  },
}
