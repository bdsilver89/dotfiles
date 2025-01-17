-- TODO: enable/disable docker automatically

if not (vim.g.enable_lang_docker ~= false) then
  return {}
end

return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = { "dockerfile" },
    },
  },

  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = { "hadolint" },
    },
  },

  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = {
      linters_by_ft = {
        dockerfile = { "hadolint" },
      },
    },
  },
}
