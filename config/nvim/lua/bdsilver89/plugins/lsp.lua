return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
      {
        "folke/neoconf.nvim",
        cmd = "Neoconf",
        config = false,
      },
      {
        "folke/neodev.nvim",
        opts = {}
      },
      "mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    opts = function()
      local Utils = require("bdsilver89.utils")
      return {
        ---@type vim.diagnostic.Opts
        diagnostics = {
          underline = true,
          update_in_insert = false,
          virtual_text = {
            spacing = 4,
            source = "if_many",
            -- prefix = "●",
          },
          severity_sort = true,
          signs = {
            text = {
              [vim.diagnostic.severity.ERROR] = Utils.ui.get_icon("diagnostics", "Error"),
              [vim.diagnostic.severity.WARN] = Utils.ui.get_icon("diagnostics", "Warn"),
              [vim.diagnostic.severity.HINT] = Utils.ui.get_icon("diagnostics", "Hint"),
              [vim.diagnostic.severity.INFO] = Utils.ui.get_icon("diagnostics", "Info"),
            },
          },
        }
      }
    end,
    config = function(_, opts)
      local Utils = require("bdsilver89.utils")

      if Utils.plugins.has("neoconf.nvim") then
        local plugin = require("lazy.core.config").spec.plugins["neoconf.nvim"]
        require("neoconf").setup(require("lazy.core.plugin").values(plugin, "opts", false))
      end

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("config_lsp_attach", { clear = true }),
        callback = function(event)
          -- TODO: keymaps
          -- TODO: inlay hints
          -- TODO: code lens
        end,
      })

      -- diagnostic signs
      if vim.fn.has("nvim-0.10") == 0 then
        for severity, icon in pairs(opts.diagnostics.signs.text) do
          local name = vim.diagnostic.severity[severity]:lower():gsub("^%l", string.upper)
          name = "DiagnosticSign" .. name
          vim.fn.sign_define(name, { text = icon, texthl = name, numhl = "" })
        end
      end

      -- diagnostic virtual text

      -- diagnostics
      vim.diagnostic.config(vim.deepcopy(opts.diagnostics))

      local servers = {}
      local has_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
      local capabilities = vim.tbl_deep_extend(
        "force",
        vim.lsp.protocol.make_client_capabilities(),
        has_cmp and cmp_nvim_lsp.default_capabilities() or {})

      local function setup(server)
        local server_opts = vim.tbl_deep_extend("force", {
          capabilities = vim.deepcopy(capabilities),
        }, servers[server] or {})

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

      local have_mason, mlsp = pcall(require, "mason-lspconfig")
      local all_mslp_servers = {}
      if have_mason then
        all_mslp_servers = vim.tbl_keys(require("mason-lspconfig.mappings.server").lspconfig_to_package)
      end

      local ensure_installed = {} ---@type string[]
      for server, server_opts in pairs(servers) do
        if server_opts then
          server_opts = server_opts == true and {} or server_opts
          -- run manual setup if mason=false or if this is a server that cannot be installed with mason-lspconfig
          if server_opts.mason == false or not vim.tbl_contains(all_mslp_servers, server) then
            setup(server)
          elseif server_opts.enabled ~= false then
            ensure_installed[#ensure_installed + 1] = server
          end
        end
      end

      if have_mason then
        mlsp.setup({ ensure_installed = ensure_installed, handlers = { setup } })
      end
    end
  }
}
