return {
  {
    "neovim/nvim-lspconfig",
    event = "LazyFile",
    cmd = { "LspInfo", "LspLog", "LspStart" },
    dependencies = {
      {
        "williamboman/mason-lspconfig.nvim",
        dependencies = {
          "mason.nvim",
        },
        cmd = { "LspInstall", "LspUninstall" },
        opts_extend = { "ensure_installed" },
        opts = {},
      },
    },
    opts = function()
      local icons = require("config.icons")

      local opts = {
        diagnostics = {
          underline = true,
          update_in_insert = false,
          virtual_text = {
            spacing = 4,
            source = "if_many",
            prefix = require("config.icons").misc.rounded_square,
          },
          severity_sort = true,
          float = {
            border = "rounded",
          },
          signs = {
            text = {
              [vim.diagnostic.severity.ERROR] = icons.diagnostics.error,
              [vim.diagnostic.severity.WARN] = icons.diagnostics.warn,
              [vim.diagnostic.severity.INFO] = icons.diagnostics.info,
              [vim.diagnostic.severity.HINT] = icons.diagnostics.hint,
            },
          },
        },
        servers = {},
        setup = {},
      }

      return opts
    end,
    config = function(_, opts)
      local lsp_util = require("plugins.core.lsp.util")

      -- lsp setup
      lsp_util.on_attach(function(client, buffer)
        require("plugins.core.lsp.keymaps").on_attach(client, buffer)
      end)
      lsp_util.setup()
      lsp_util.on_dynamic_capability(require("plugins.core.lsp.keymaps").on_attach)

      -- diagnostics setup
      vim.diagnostic.config(vim.deepcopy(opts.diagnostics))

      -- default border style
      local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
      function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
        opts = opts or {}
        opts.border = "rounded"
        return orig_util_open_floating_preview(contents, syntax, opts, ...)
      end

      local servers = opts.servers
      local has_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
      local has_blink, blink = pcall(require, "blink.cmp")
      local capabilities = vim.tbl_deep_extend(
        "force",
        {},
        vim.lsp.protocol.make_client_capabilities(),
        has_cmp and cmp_nvim_lsp.default_capabilities() or {},
        has_blink and blink.get_lsp_capabilities() or {},
        opts.capabilities or {}
      )

      local function setup(server)
        local server_opts = vim.tbl_deep_extend("force", {
          capabilities = vim.deepcopy(capabilities),
        }, servers[server] or {})
        if server_opts.enabled == false then
          return
        end

        if opts.setup[server] then
          if opts.setup[server](server, server_opts) then
            return
          end
        elseif opts.setup["*"] then
          if opts.setup["*"](server, server_opts) then
            return
          end
        end
        require("lspconfig")[server].setup(server_opts)
      end

      -- local have_mlsp, mlsp = pcall(require, "mason-lspconfig")
      -- local all_mlsp_servers = {}
      -- if has_mlsp then
      --   all_mlsp_servers = vim.tbl_keys(require("mason-lspconfig.mappings.server").lspconfig_to_package)
      -- end

      for server, server_opts in pairs(servers) do
        if server_opts then
          server_opts = server_opts == true and {} or server_opts
          if server_opts.enabled ~= false then
            setup(server)
          end
        end
      end
    end,
  },
}
