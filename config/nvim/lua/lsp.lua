vim.pack.add({
  "https://github.com/mason-org/mason.nvim",
  "https://github.com/mason-org/mason-lspconfig.nvim",
  "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim",
  "https://github.com/neovim/nvim-lspconfig",
})

vim.diagnostic.config({
  virtual_text = true,
})

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("config_lspattach", { clear = true }),
  callback = function(ev)
    local buf = ev.buf
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client == nil then
      return
    end

    local function opts(desc)
      return { buffer = buf, silent = true, desc = desc }
    end

    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts("Go to definition"))
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts("Go to declaration"))
  end,
})

vim.schedule(function()
  require("mason").setup()
  require("mason-lspconfig").setup()
  require("mason-tool-installer").setup({
    ensure_installed = {
      "stylua",
      "lua_ls",
    },
  })
end)
