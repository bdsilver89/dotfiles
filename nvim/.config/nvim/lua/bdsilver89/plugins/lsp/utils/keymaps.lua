local M = {}

M._keys = nil

function M.get()
  local format = function()
    require("bdsilver89.plugins.lsp.utils.format").format({ force = true })
  end

  if not M._keys then
    M._keys = {
      { "<leader>cd", vim.diagnostic.open_float, desc = "Line diagnostics" },
      { "<leader>cl", "<cmd>LspInfo<cr>", desc = "Lsp info" },
      { "gd", "<cmd>Telescope lsp_definitions<cr>", desc = "Goto definition", has = "definition" },
      { "gr", "<cmd>Telescope lsp_references<cr>", desc = "References" },
      { "gD", vim.lsp.buf.declaration, desc = "Goto declaration" },
      { "gI", "<cmd>Telescope lsp_implementations<cr>", desc =  "Goto implementation" },
      { "gy", "<cmd>Telescope lsp_type_defintions<cr>", desc =  "Goto type implementation" },
      { "K", vim.lsp.buf.hover, desc = "Hover" },
      { "gK", vim.lsp.buf.signature_help, desc = "Signature help", has = "signatureHelp" },
      { "<c-k>", vim.lsp.buf.signature_help, mode = "i", desc = "Signature help", has = "signatureHelp" },
      { "]d", M.diagnostic_goto(true), desc = "Next diagnostic" },
      { "[d", M.diagnostic_goto(false), desc = "Previous diagnostic" },
      { "]e", M.diagnostic_goto(true, "ERROR"), desc = "Next error" },
      { "[e", M.diagnostic_goto(false, "ERROR"), desc = "Previous error" },
      { "]w", M.diagnostic_goto(true, "WARN"), desc = "Next warning" },
      { "[w", M.diagnostic_goto(false, "WARN"), desc = "Previous warning" },
      { "<leader>cf", format, desc = "Format document", has = "documentFormatting" },
      { "<leader>cf", format, mode = "v", desc = "Format range", has = "documentFormatting" },
      { "<leader>ca", vim.lsp.buf.code_action, mode = { "n", "v" }, desc = "Code action", has = "codeAction" },
    }
  end
  return M._keys
end

function M.on_attach(client, buffer)
  local Keys = require("lazy.core.handler.keys")
  local keymaps = {}

  for _, value in ipairs(M.get()) do
    local keys = Keys.parse(value)
    if keys[2] == vim.NIL or keys[2] == false then
      keymaps[keys.id] = nil
    else
      keymaps[keys.id] = keys
    end
  end

  for _, keys in pairs(keymaps) do
    if not keys.has or client.server_capabilities[keys.has .. "Provider"] then
      local opts = Keys.opts(keys)
      opts.has = nil
      opts.silent = opts.silent ~= false
      opts.buffer = buffer
      vim.keymap.set(keys.mode or "n", keys[1], keys[2], opts)
    end
  end
end

function M.diagnostic_goto(next, severity)
  local go = next and vim.diagnostic.goto_next or vim.diagnostic.goto_prev
  severity = severity and vim.diagnostic.severity[severity] or nil
  return function()
    go({ severity = severity })
  end
end

return M
