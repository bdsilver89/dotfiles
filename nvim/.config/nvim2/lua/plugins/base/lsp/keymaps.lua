local utils = require("config.utils")

local M = {}

local diagnostics_active = true

local function toggle_diagnostics()
  diagnostics_active = not diagnostics_active
  if diagnostics_active then
    vim.diagnostic.show()
    utils.info("Enabled diagnostics", { title = "Diagnostics" })
  else
    vim.diagnostic.hide()
    utils.warn("Disabled diagnostics", { title = "Diagnostics" })
  end
end

local function format()
  require("plugins.base.lsp.format").format({ force = true })
end

local function toggle_formatting()
  require("plugins.base.lsp.format").toggle()
end

function M.on_attach(client, buffer)
  local self = M.new(client, buffer)

  self:map("gd", "<cmd>Telescope lsp_definitions<cr>", { desc = "Goto Definitions" })
  self:map("gD", vim.lsp.buf.declaration, { desc = "Goto Declaration" })
  self:map("gr", "<cmd>Telescope lsp_references<cr>", { desc = "References" })
  self:map("K", vim.lsp.buf.hover, { desc = "Hover" })
  self:map("gI", "<cmd>Telescope lsp_implementationr<cr>", { desc = "Goto Implementation" })
  self:map("gb", "<cmd>Telescope lsp_type_definitions<cr>", { desc = "Goto Type Definition" })
  self:map("gK", vim.lsp.buf.signature_help, { desc = "Signature Help", has = "signatureHelp" })
  self:map("<c-k>", vim.lsp.buf.signature_help, { mode = "i", desc = "Signature Help", has = "signatureHelp" })
  self:map("[d", M.diagnostic_goto(true), { desc = "Next Diagnostic" })
  self:map("]d", M.diagnostic_goto(false), { desc = "Prev Diagnostic" })
  self:map("[e", M.diagnostic_goto(true, "ERROR"), { desc = "Next Error" })
  self:map("]e", M.diagnostic_goto(false, "ERROR"), { desc = "Prev Error" })
  self:map("[w", M.diagnostic_goto(true, "WARNING"), { desc = "Next Warning" })
  self:map("]w", M.diagnostic_goto(false, "WARNING"), { desc = "Prev Warning" })
  self:map("<leader>ca", vim.lsp.buf.code_action, { desc = "Code Action", mode = { "n", "v" }, has = "codeAction" })
  self:map("<leader>cA", function()
    vim.lsp.buf.code_action({
      context = {
        only = { "source" },
        diagnostics = {},
      },
    })
  end, { desc = "Code Action", has = "codeAction" })

  self:map("<leader>cF", function() toggle_formatting() end, { desc = "Toggle formatting", has = "documentFormatting" })
  self:map("<leader>cf", function() format() end, { desc = "Format Document", has = "documentFormatting" })
  self:map("<leader>cf", function() format() end, { desc = "Format Range", mode = "v", has = "documentFormatting" })

  self:map("<leader>cs", require("telescope.builtin").lsp_document_symbols, { desc = "Document Symbols" })
  self:map("<leader>cS", require("telescope.builtin").lsp_dynamic_workspace_symbols, { desc = "Workspace Symbols" })
  self:map("<leader>cw", function() toggle_diagnostics() end(), { desc = "Toggle Inline Diagnostics" })
  self:map("<leader>cd", vim.diagnostic.open_float, { desc = "Line Diagnostic" })
  self:map("<leader>cl", "<cmd>LspInfo<cr>", { desc = "Lsp Info" })
end

function M.new(client, buffer)
  return setmetatable({ client = client, buffer = buffer }, { __index = M })
end

function M:has(cap)
  return self.client.server_capabilities[cap .. "Provider"]
end

function M:map(lhs, rhs, opts)
  opts = opts or {}
  if opts.has and not self:has(opts.has) then
    return
  end
  vim.keymap.set(
    opts.mode or "n",
    lhs,
    rhs,
    { silent = true, buffer = self.buffer, expr = opts.expr, desc = opts.desc }
  )
end

function M.diagnostic_goto(next, severity)
  local go = next and vim.diagnostic.goto_next or vim.diagnostic.goto_prev
  severity = severity and vim.diagnostic.severity[severity] or nil
  return function()
    go({ severity = severity })
  end
end

return M
