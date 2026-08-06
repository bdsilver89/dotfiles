local pack = require("pack")
local icons = require("icons")

pack.add({
  { src = "neovim/nvim-lspconfig", setup = false },
})

vim.diagnostic.config({
  severity_sort = true,
  update_in_insert = false,
  virtual_text = true,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = icons.diagnostics.ERROR,
      [vim.diagnostic.severity.WARN] = icons.diagnostics.WARN,
      [vim.diagnostic.severity.INFO] = icons.diagnostics.INFO,
      [vim.diagnostic.severity.HINT] = icons.diagnostics.HINT,
    },
  },
})

---@param client vim.lsp.Client
---@param bufnr integer
local function on_attach(client, bufnr)
end

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("config_lspattach", { clear = true }),
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client then
      on_attach(client, ev.buf)
    end
  end,
})

vim.keymap.set("n", "<leader>xq", function()
  local open = vim.fn.getqflist({ winid = 0 }).winid ~=0
  vim.cmd(open and "cclose" or "copen")
end, { desc = "Toggle quickfix" })

vim.keymap.set("n", "<leader>xl", function()
  local open = vim.fn.getloclist(0, { winid = 0 }).winid ~=0
  vim.cmd(open and "lclose" or "lopen")
end, { desc = "Toggle location list" })

