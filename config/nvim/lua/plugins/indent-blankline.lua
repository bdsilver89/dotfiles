return {
  {
    "lukas-reineke/indent-blankline.nvim",
    event = { "BufReadPost", "BufNewFile" },
    cmd = {
      "IBLEnable",
      "IBLDisable",
      "IBLToggle",
      "IBLEnableScope",
      "IBLDisableScope",
      "IBLToggleScope"
    },
    keys = {
      { "<leader>u|", "<cmd>IBLToggle<cr>", desc = "Toggle indent guides" },
    },
    opts = {
      indent = { char = "▏" },
      scope = {
        show_start = false,
        show_end = false
      },
      exclude = {
        buftypes = {
          "nofile",
          "prompt",
          "quickfix",
          "terminal",
        },
        filetypes = {
          "help",
          "lazy",
          "mason",
          "neo-tree",
          "neogitstatus",
          "notify",
          "toggleterm",
          "Trouble",
          "trouble",
        },
      },
    },
    main = "ibl",
  }
}
