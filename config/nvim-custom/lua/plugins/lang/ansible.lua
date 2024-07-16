return {
  -- {
  --   "nvim-treesitter/nvim-treesitter",
  --   opts = {
  --     ensure_installed = { "ansible" },
  --   },
  -- },

  {
    "williamboman/mason.nvim",
    optional = true,
    opts = {
      ensure_installed = { "ansible-lint" },
    },
  },

  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ansiblels = {},
      },
    },
  },

  {
    "mfussenegger/nvim-ansible",
    ft = {},
    keys = {
      {
        "<leader>ta",
        function()
          require("ansible").run()
        end,
        desc = "Ansible Run Playbook/Role",
        silent = true,
      },
    },
  },
}
