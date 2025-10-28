return {
  "lukas-reineke/indent-blankline.nvim",
  event = { "BufReadPost", "BufNewFile" },
  opts = {
    scope = {
      show_start = true,
    },
  },
  main = "ibl",
}
