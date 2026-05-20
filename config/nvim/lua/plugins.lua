vim.pack.add({
  "https://github.com/catppuccin/nvim",
  "https://github.com/nvim-mini/mini.nvim",
  "https://github.com/nvim-treesitter/nvim-treesitter",
  "https://github.com/nvim-treesitter/nvim-treesitter-textobjects",
  "https://github.com/neovim/nvim-lspconfig",
  "https://github.com/mason-org/mason.nvim",
  "https://github.com/stevearc/oil.nvim",
})

require("catppuccin").setup()
vim.cmd.colorscheme("catppuccin-macchiato")

require("nvim-treesitter").setup({
  ensure_installed = {
    "bash",
    "c",
    "cpp",
    "cmake",
    "java",
    "markdown",
    "make",
    "rust",
    "python",
    "toml",
    "javascript",
    "typescript",
    "tsx",
    "json",
    "lua",
    "yaml",
    "xml",
  },
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = function(ev)
    local ft = vim.bo[ev.buf].filetype
    local lang = vim.treesitter.language.get_lang(ft)
    if not lang then
      return
    end

    pcall(vim.treesitter.language.add, lang)
    pcall(vim.treesitter.start, ev.buf, lang)

    vim.wo[0].foldmethod = "expr"
    vim.wo[0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
    vim.b[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end
})

require("mason").setup()
local mr = require("mason-registry")
mr.refresh(function()
  for _, tool in ipairs({
    "lua-language-server",
    "stylua",
  }) do
    local p = mr.get_package(tool)
    if not p:is_installed() then
      p:install()
    end
  end
end)

require("oil").setup()
vim.keymap.set("n", "-", "<cmd>Oil<cr>", { desc = "Oil" })
