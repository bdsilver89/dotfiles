local add = MiniDeps.add

add("mason-org/mason-lspconfig.nvim")
add("mason-org/mason.nvim")
add("neovim/nvim-lspconfig")
add("WhoIsSethDaniel/mason-tool-installer.nvim")

require("mason").setup()
require("mason-lspconfig").setup()
require("mason-tool-installer").setup({
  ensure_installed = {
    "stylua",
    "lua_ls",
  },
  auto_update = false,
  run_on_start = true,
})

vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" },
      },
      workspace = {
        checkThirdParty = false,
        library = {
          [vim.fn.expand("$VIMRUNTIME/lua")] = true,
          [vim.fn.expand("$VIMRUNTIME/lua/vim/lsp")] = true,
          [vim.fn.stdpath("config") .. "/lua"] = true,
          [vim.fn.stdpath("data") .. "/lua"] = true,
          ["${3rd}/luv/library"] = true,
        },
      },
    },
  },
})

vim.lsp.enable({
  "lua_ls",
  "clangd",
})

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("lspattach", { clear = true }),
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if not client then
      return
    end

    local map = function(lhs, rhs, desc)
      vim.keymap.set("n", lhs, rhs, { desc = desc, buffer = ev.buf })
    end

    map("gd", vim.lsp.buf.definition, "vim.lsp.buf.definition")
    map("gD", vim.lsp.buf.declaration, "vim.lsp.buf.declaration")
    map("gW", vim.lsp.buf.workspace_symbol, "vim.lsp.buf.workspace_symbol")
  end,
})

vim.diagnostic.config({
  severity_sort = true,
  underline = true,
  virtual_text = true,
})
