local M = {}

function M.get_clients(...)
  ---@diagnostic disable-next-line: deprecated
  local fn = vim.lsp.get_clients or vim.lsp.get_active_clients
  return fn(...)
end

---@param fn fun(client, buffer)
function M.on_attach(fn)
  vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
      local buffer = args.buf ---@type number
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      fn(client, buffer)
    end,
  })
end

-- TODO: on_rename

function M.get_config(server)
  local configs = require("lspconfig.configs")
  return rawget(configs, server)
end

return M
