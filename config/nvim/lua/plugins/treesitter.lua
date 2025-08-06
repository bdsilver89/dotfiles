local add = MiniDeps.add

add({
  source = "nvim-treesitter/nvim-treesitter",
  checkout = "master",
  hooks = {
    post_checkout = function()
      vim.cmd("TSUpdate")
    end,
  },
})

add({
  source = "nvim-treesitter/nvim-treesitter-textobjects",
  checkout = "master",
})

add({
  source = "nvim-treesitter/nvim-treesitter-context",
  checkout = "master",
})

require("nvim-treesitter.configs").setup({
  ensure_installed = {
    "bash",
    "c",
  },
  highlight = { enable = true },
  indent = { enable = true },
  textobjects = {
    move = {
      enable = true,
    },
    select = {
      enable = true,
    },
  },
})

require("treesitter-context").setup()
