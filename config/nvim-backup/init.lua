if vim.loader and vim.fn.has("nvim-0.9.1") == 1 then
  vim.loader.enable()
end

require("config")
