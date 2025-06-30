return {
  "catppuccin/nvim",
  name = "catppuccin",
  lazy = false,
  priority = 1000,
  opts = {
    integrations = {
      blink_cmp = true,
      dadbod_ui = true,
      dap = true,
      dap_ui = true,
      cmp = true,
      fzf = true,
      grug_far = true,
      gitsigns = true,
      harpoon = true,
      indent_blankline = { enabled = true },
      mason = true,
      mini = true,
      native_lsp = {
        enabled = true,
        underlines = {
          errors = { "undercurl" },
          hints = { "undercurl" },
          warnings = { "undercurl" },
          information = { "undercurl" },
        },
      },
      neogit = true,
      neotest = true,
      overseer = true,
      snacks = true,
      telescope = true,
      treesitter = true,
      which_key = true,
    },
  },
  specs = {
    {
      "akinsho/bufferline.nvim",
      optional = true,
      opts = function(_, opts)
        if (vim.g.colors_name or ""):find("catppuccin") then
          opts.highlights = require("catppuccin.groups.integrations.bufferline").get()
        end
      end,
    },
  },
  config = function(_, opts)
    require("catppuccin").setup(opts)
    if not vim.g.vscode then
      vim.cmd.colorscheme("catppuccin")
    end
  end,
}
