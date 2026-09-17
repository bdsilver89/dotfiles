vim.diagnostic.config({
  severity_sort = true,
  virtual_text = { current = true },
})

local group = vim.api.nvim_create_augroup("configlsp", { clear = true })

vim.api.nvim_create_autocmd("LspAttach", {
  group = group,
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
  end,
})

vim.api.nvim_create_autocmd({ "BufReadPre", "BufNewFile" }, {
  once = true,
  callback = function()
    local servers = vim.iter(vim.api.nvim_get_runtime_file("lsp/*.lua", true))
      :map(function(file)
        return vim.fn.fnamemodify(file, ":t:r")
      end)
      :filter(function(server)
        return server ~= "jdtls"
      end)
      :totable()
    vim.lsp.enable(servers)
  end,
})
