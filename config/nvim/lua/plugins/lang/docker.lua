if vim.fn.executable("docker") == 1 then
  return {}
end

return {
  {
    "nvim-treesitter",
    opts = { ensure_installed = { "dockerfile" } },
  },
}
