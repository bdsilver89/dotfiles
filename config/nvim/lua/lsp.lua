local configs = {}
for _, c in ipairs(vim.api.nvim_get_runtime_file("lsp/*.lua", true)) do
  configs[#configs + 1] = vim.fn.fnamemodify(c, ":t:r")
end
vim.lsp.enable(configs)

vim.api.nvim_create_user_command("LspStart", function(args)
  local server = args.fargs[1]
  if server then
    vim.lsp.enable(server)
  else
    vim.lsp.enable(configs)
  end
end, {
  nargs = "?",
  complete = function()
    return configs
  end,
})

vim.api.nvim_create_user_command("LspStop", function(args)
  local server = args.fargs[1]
  local clients = vim.lsp.get_clients({ name = server })
  if #clients == 0 then
    clients = vim.lsp.get_clients()
  end
  for _, client in ipairs(clients) do
    client:stop()
  end
end, {
  nargs = "?",
  complete = function()
    return vim.tbl_map(function(c) return c.name end, vim.lsp.get_clients())
  end,
})

local group = vim.api.nvim_create_augroup("lsp", { clear = true })

-- vim.api.nvim_create_autocmd("LspDetach", {
--   group = group,
--   callback = function(ev)
--   end,
-- })

vim.api.nvim_create_autocmd("LspAttach", {
  group = group,
  callback = function(ev)
    local buf = ev.buf
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client == nil then
      return
    end

    local map = function(mode, lhs, rhs, opts)
      opts = opts or {}
      opts.buffer = buf
      vim.keymap.set(mode, lhs, rhs, opts)
    end

    map("n", "grd", vim.lsp.buf.definition, { desc = "vim.lsp.buf.definition()" })
    map("n", "grD", vim.lsp.buf.declaration, { desc = "vim.lsp.buf.declaration()" })
    map("n", "grf", vim.lsp.buf.format, { desc = "vim.lsp.buf.format()" })
    map("n", "grs", vim.lsp.buf.signature_help, { desc = "vim.lsp.buf.signature_help" })
    map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "vim.diagnostic.open_float" })
    map("n", "<leader>cq", vim.diagnostic.setqflist, { desc = "vim.diagnostic.setqflist" })
    map("n", "<leader>cl", vim.diagnostic.setloclist, { desc = "vim.diagnostic.setloclist" })


    vim.diagnostic.config({
      severity_sort = true,
      underline = true,
      virtual_text = true,
      virtual_lines = {
        current_line = true,
      },
    })
  end,
})
