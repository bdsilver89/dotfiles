local add = MiniDeps.add

add("nvim-lua/plenary.nvim")
add("MeanderingProgrammer/render-markdown.nvim")
add("MunifTanjim/nui.nvim")
add("j-hui/fidget.nvim")

require("render-markdown").setup({
  code = {
    sign = false,
    width = "block",
    right_pad = 1,
  },
  heading = {
    sign = true,
    icons = {},
  },
})

require("fidget").setup()
