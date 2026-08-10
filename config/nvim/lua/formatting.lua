local M = {}

M.formatters = {}

vim.api.nvim_create_autocmd("BufWritePre", {
  group = vim.api.nvim_create_augroup("autoformat", { clear = true }),
  callback = function(ev)
    local buf = ev.buf
    local ft = vim.bo[buf].filetype
    local cmd = M.formatters[ft]

    if cmd then
      local bufname = vim.api.nvim_buf_get_name(buf)
      local resolved = cmd:gsub("%%", bufname)
      local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
      local input = table.concat(lines, "\n")
      local output = vim.fn.system(resolved, input)
      if vim.v.shell_error == 0 then
        local formatted = vim.split(output, "\n", { plain = true })
        if formatted[#formatetd] == "" then
          table.remove(formatted)
        end
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, formatted)
      end
    else
      for _, cl in ipairs(vim.lsp.get_clients({ bufnr = buf })) do
        if cl:supports_method("textDoument/formatting") then
          vim.lsp.buf.format({ bufnr = buf, async = false })
          break
        end
      end
    end
  end,
})


return M
