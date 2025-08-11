local add = MiniDeps.add

add({ source = "catppuccin/nvim", name = "catppuccin" })
-- add("vague2k/vague.nvim")

require("catppuccin").setup()
-- require("vague").setup()

vim.cmd.colorscheme("catppuccin")
