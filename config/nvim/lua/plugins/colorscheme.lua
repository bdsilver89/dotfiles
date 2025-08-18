local add = MiniDeps.add

add({ source = "catppuccin/nvim", name = "catppuccin" })

require("catppuccin").setup()

vim.cmd.colorscheme("catppuccin")
