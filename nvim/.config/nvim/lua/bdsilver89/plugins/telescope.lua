local Util = require("bdsilver89.utils")

return {
  "nvim-telescope/telescope.nvim",
  cmd = "Telescope",
  dependencies = {
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      enabled = vim.fn.executable("make") == 1,
      build = "make",
      config = function()
        require("telescope").load_extension("fzf")
      end,
    },
    {
      "debugloop/telescope-undo.nvim",
      config = function()
        require("telescope").load_extension("undo")
      end,
    },
  },
  keys = {
    { "<leader>,", "<cmd>Telescope buffers show_all_buffers=true<cr>", desc = "Switch buffer" },
    { "<leader>/", Util.telescope("live_grep"), desc = "Grep (root dir)" },
    { "<leader>:", "<cmd>Telescope command_history<cr>", desc = "Command history" },
    { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
    { "<leader>ff", Util.telescope("files"), desc = "Find files (root dir)" },
    { "<leader>fF", Util.telescope("files", { cwd = false }), desc = "Find files (cwd)" },
    { "<leader>fr", Util.telescope("oldfiles"), desc = "Recent files" },
    { "<leader>fR", Util.telescope("oldfiles", { cwd = false }), desc = "Recent files (cwd)" },
    -- TODO: add git commits and status?
    -- search
    { "<leader>sa", "<cmd>Telescope autocommands<cr>", desc = "Search autocommands" },
    { "<leader>sb", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Search in buffer" },
    { "<leader>sc", "<cmd>Telescope command_history<cr>", desc = "Search in command history" },
    { "<leader>sC", "<cmd>Telescope commands<cr>", desc = "Search commands" },
    { "<leader>sd", "<cmd>Telescope diagnostics bufnr=0<cr>", desc = "Document diagnostics" },
    { "<leader>sD", "<cmd>Telescope diagnostics<cr>", desc = "Workspace diagnostics" },
    { "<leader>sg", Util.telescope("live_grep"), desc = "Grep (root dir)" },
    { "<leader>sG", Util.telescope("live_grep", { cwd = false }), desc = "Grep (cwd)" },
    { "<leader>sh", "<cmd>Telescope help_tags<cr>", desc = "Help pages" },
    { "<leader>sH", "<cmd>Telescope highlight<cr>", desc = "Search highlight groups" },
    { "<leader>sk", "<cmd>Telescope keymaps<cr>", desc = "Keymaps" },
    { "<leader>sM", "<cmd>Telescope man_pages<cr>", desc = "Man pages" },
    -- { "<leader>sm", "<cmd>Telescope marks<cr>", desc = "Marks" },
    { "<leader>so", "<cmd>Telescope vim_options<cr>", desc = "Options" },
    { "<leader>su", "<cmd>Telescope undo<cr>", desc = "Undo" },

    -- { "<leader>sp", "<cmd>Telescope lazy<cr>", desc = "Plugins" },
    -- { "<leader>ss", "<cmd>Telescope luasnip<cr>", desc = "Snippets" },
    -- { "<leader>sR", "<cmd>Telescope resume<cr>", desc = "Resume" },
    { "<leader>sw", Util.telescope("grep_string"), desc = "Word (root dir)" },
    { "<leader>sW", Util.telescope("grep_string", { cwd = false }), desc = "Word (cwd)" },
    { "<leader>uC", Util.telescope("colorscheme", { enable_preview = true }), desc = "Colorscheme" },
    {
      "<leader>ss",
      Util.telescope("lsp_document_symbols", {
        symbols = {
          "Class",
          "Function",
          "Method",
          "Constructor",
          "Interface",
          "Module",
          "Struct",
          "Trait",
          "Field",
          "Property",
        },
      }),
      desc = "Goto symbol",
    },
    {
      "<leader>sS",
      Util.telescope("lsp_dynamic_document_symbols", {
        symbols = {
          "Class",
          "Function",
          "Method",
          "Constructor",
          "Interface",
          "Module",
          "Struct",
          "Trait",
          "Field",
          "Property",
        },
      }),
      desc = "Goto symbol (workspace)",
    },
  },
  opts = function()
    local actions = require("telescope.actions")
    return {
      defaults = {
        prompt_prefix = " ",
        selection_caret = " ",
        path_display = {
          "truncate",
        },
        layout_strategy = "horizontal",
        layout_config = {
          -- prompt_position = "top",
          horizontal = { prompt_position = "top", preview_width = 0.55 },
          vertical = { mirror = false },
          width = 0.87,
          height = 0.80,
          preview_cutoff = 120,
        },
        sorting_strategy = "ascending",
        winblend = 0,
        mappings = {
          i = {
            ["<c-down>"] = actions.cycle_history_next,
            ["<c-up>"] = actions.cycle_history_prev,
            ["<c-f>"] = actions.preview_scrolling_down,
            ["<c-b>"] = actions.preview_scrolling_up,
          },
          n = {
            ["q"] = actions.close,
          },
        },
      },
    }
  end,
  config = function(_, opts)
    local telescope = require("telescope")
    telescope.setup(opts)

    telescope.load_extension("notify")
    telescope.load_extension("fzf")
  end,
}
