if not require("bdsilver89.config.lang").langs.zig then
  return {}
end

return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, { "zig" })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "ziglang/zig.vim",
    },
    opts = {
      servers = {
        zls = {},
      },
    },
  },
}
