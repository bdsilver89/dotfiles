local function get_codelldb()
  local mason_registry = require("mason-registry")
  local codelldb = mason_registry.get_package("codelldb")
  local extension_path = codelldb:get_install_path() .. "/extension"
  local codelldb_path = extension_path .. "adapter/codelldb"
  local liblldb_path = extension_path .. "lldb/lib/liblldb.so"
  return codelldb_path, liblldb_path
end

return {
  -- NOTE: do not configure DAP for rust here, it is handled through cpp lang setup
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, { "rust" })
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
