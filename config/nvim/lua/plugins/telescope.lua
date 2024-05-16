return {
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    dependencies = {
      {
        "nvim-lua/plenary.nvim",
      },
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        cond = function()
          return vim.fn.executable("make") == 1
        end,
      },
    },
    -- stylua: ignore
    keys = {
      { "<leader>,",       "<cmd>Telescope buffers sort_mru=true sort_lastused=true<cr>", desc = "Switch buffer" },
      { "<leader>/",       "<cmd>Telescope live_grep<cr>",                                desc = "Grep" },
      { "<leader>:",       "<cmd>Telescope history<cr>",                                  desc = "Command history" },
      { "<leader><space>", "<cmd>Telescope find_files<cr>",                               desc = "Find files" },
      -- find
      { "<leader>fb",      "<cmd>Telescope buffers sort_mru=true sort_lastused=true<cr>", desc = "Buffers" },
      { "<leader>ff",      "<cmd>Telescope find_files<cr>",                               desc = "Find files" },
      { "<leader>fg",      "<cmd>Telescope git_files<cr>",                                desc = "Git files" },
      { "<leader>fr",      "<cmd>Telescope oldfiles<cr>",                                 desc = "Recent" },
      -- git
      { "<leader>gC",      "<cmd>Telescope git_commits<cr>",                              desc = "Commits" },
      -- { "<leader>gs", "<cmd>Telescope git_status<cr>", desc = "Status" },
      { "<leader>gb",      "<cmd>Telescope git_branches<cr>",                             desc = "Branches" },
      -- search
      { '<leader>s"',      "<cmd>Telescope registers<cr>",                                desc = "Registers" },
      { "<leader>sa",      "<cmd>Telescope autocommands<cr>",                             desc = "Autocommands" },
      { "<leader>sb",      "<cmd>Telescope current_buffer_fuzzy_find<cr>",                desc = "Buffer" },
      { "<leader>sc",      "<cmd>Telescope command_history<cr>",                          desc = "Command history" },
      { "<leader>sC",      "<cmd>Telescope commands<cr>",                                 desc = "Commands" },
      { "<leader>sd",      "<cmd>Telescope diagnostics bufnr=0<cr>",                      desc = "Document diagnostics" },
      { "<leader>sD",      "<cmd>Telescope diagnostics<cr>",                              desc = "Workspace diagnostics" },
      { "<leader>sg",      "<cmd>Telescope live_grep<cr>",                                desc = "Grep" },
      -- { "<leader>sG", LazyVim.telescope("live_grep", { cwd = false }), desc = "Grep" },
      { "<leader>sh",      "<cmd>Telescope help_tags<cr>",                                desc = "Help pages" },
      { "<leader>sH",      "<cmd>Telescope highlights<cr>",                               desc = "Search highlight groups" },
      { "<leader>sk",      "<cmd>Telescope keymaps<cr>",                                  desc = "Keymaps" },
      { "<leader>sM",      "<cmd>Telescope man_pages<cr>",                                desc = "Man pages" },
      -- { "<leader>sm", "<cmd>Telescope marks<cr>", desc = "Jump to mark" },
      { "<leader>so",      "<cmd>Telescope vim_options<cr>",                              desc = "Options" },
      { "<leader>sR",      "<cmd>Telescope resume<cr>",                                   desc = "Resume" },
      { "<leader>sw",      "<cmd>Telescope grep_string<cr>",                              desc = "Word" },
      { "<leader>sw",      "<cmd>Telescope grep_string<cr>",                              mode = "v",                      desc = "Selection" },
      -- { "<leader>uC", LazyVim.telescope("colorscheme", { enable_preview = true }), desc = "Colorscheme with Preview" },
      {
        "<leader>ss",
        function()
          require("telescope.builtin").lsp_document_symbols({
            symbols = require("lazyvim.config").get_kind_filter(),
          })
        end,
        desc = "Goto symbol",
      },
      {
        "<leader>sS",
        function()
          require("telescope.builtin").lsp_dynamic_workspace_symbols({
            symbols = require("lazyvim.config").get_kind_filter(),
          })
        end,
        desc = "Goto symbol (workspace)",
      },
    },
    config = function()
      require("telescope").setup({
        defaults = {
          sorting_strategy = "ascending",
          layout_strategy = "horizontal",
          layout_config = {
            horizontal = {
              prompt_position = "top",
            },
            vertical = {
              mirror = false,
            },
          },
        },
        extensions = {},
      })

      pcall(require("telescope").load_extension, "fzf")
    end,
  },
}
