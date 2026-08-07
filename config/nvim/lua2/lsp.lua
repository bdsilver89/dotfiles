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

vim.api.nvim_create_autocmd({ "BufReadPre", "BufNewFile" }, {
  group = vim.api.nvim_create_augroup("config_lspenable", { clear = true }),
  once = true,
  callback = function(ev)
    vim.lsp.enable({
      "lua_ls",
    })

    vim.api.nvim_exec_autocmds("FileType", { buffer = ev.buf, modeline = false })
  end,
})

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("config_lspattach", { clear = true }),
  callback = function(ev)
    local buf = ev.buf
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client == nil then
      return
    end

    vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition", buffer = buf })
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { desc = "Go to definition", buffer = buf })
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

