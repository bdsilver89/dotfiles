local M = {}

local lsp_utils = require("bdsilver89.plugins.lsp.utils")
local utils = require("bdsilver89.utils")

local function lsp_init()
  local signs = {
    { name = "DiagnosticSignError", text = utils.get_icon("DiagnosticError"), texthl = "DiagnosticSignError" },
    { name = "DiagnosticSignWarn", text = utils.get_icon("DiagnosticWarn"), texthl = "DiagnosticSignWarn" },
    { name = "DiagnosticSignHint", text = utils.get_icon("DiagnosticHint"), texthl = "DiagnosticSignHint" },
    { name = "DiagnosticSignInfo", text = utils.get_icon("DiagnosticInfo"), texthl = "DiagnosticSignInfo" },
  }
  for _, sign in ipairs(signs) do
    vim.fn.sign_define(sign.name, sign)
  end

  -- lsp handlers
  local config = {
    float = {
      focusable = true,
      style = "minimal",
      border = "rounded",
    },
    diagnostic = {
      virtual_text = {
        severity = {
          min = vim.diagnostic.severity.ERROR,
        },
      },
      signs = {
        active = signs,
      },
      underline = false,
      update_in_insert = false,
      severity_sort = true,
      float = {
        focusable = true,
        style = "minimal",
        border = "rounded",
        source = "always",
        header = "",
        prefix = "",
      },
    },
  }

  vim.diagnostic.config(config.diagnostic)
end

function M.setup(_, opts)
  lsp_utils.on_attach(function(client, buffer)
    require("bdsilver89.plugins.lsp.format").on_attach(client, buffer)
    require("bdsilver89.plugins.lsp.keymaps").on_attach(client, buffer)

    if client.server_capabilities.documentSymbolProvider then
      require("nvim-navic").attach(client, buffer)
    end
  end)

  lsp_init()

  local servers = opts.servers
  local capabilities = lsp_utils.capabilities()

  local function setup(server)
    local server_opts = vim.tbl_deep_extend("force", {
      capabilities = capabilities,
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

  -- TODO: bun/deno?

  -- get all servers avaiable through mason lspconfig
  local have_mason, mlsp = pcall(require, "mason-lspconfig")
  local all_mlsp_servers = {}
  if have_mason then
    all_mlsp_servers = vim.tbl_keys(require("mason-lspconfig.mappings.server").lspconfig_to_package)
  end

  local ensure_installed = {} ---@type string[]
  for server, server_opts in pairs(servers) do
    if server_opts then
      server_opts = server_opts == true and {} or server_opts
      -- run manual setup if mason=false or if this is a server that cannot be installed with mason-lspconfig
      if server_opts.mason == false or not vim.tbl_contains(all_mlsp_servers, server) then
        setup(server)
      else
        ensure_installed[#ensure_installed + 1] = server
      end
    end
  end

  if have_mason then
    mlsp.setup({ ensure_installed = ensure_installed })
    mlsp.setup_handlers({ setup })
  end
end

return M
