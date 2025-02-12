vim.g.enable_lang_meson = vim.fn.executable("meson") == 1

if not (vim.g.enable_lang_meson ~= false) then
  return {}
end

return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = { "meson", "ninja" },
    },
  },

  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "mesonlsp",
      },
    },
  },

  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        mesonlsp = {},
      },
    },
  },
}
