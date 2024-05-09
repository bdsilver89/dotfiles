return {
 -- telescope finder
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    dependencies = {
      { "nvim-lua/plenary.nvim" },
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        cond = function()
          return vim.fn.executable("make") == 1
        end
      },
    },
    keys = function()
      local builtin = require("telescope.builtin")
      local keys = {
        { "<leader>,", "<cmd>Telescope buffers sort_mru=true sort_lastused=true<cr>", desc = "Switch buffer" },
        { "<leader>/", "<cmd>Telescope live_grep<cr>", desc = "Grep" },
        { "<leader>:", "<cmd>Telescope history<cr>", desc = "Command history" },
        { "<leader><space>", "<cmd>Telescope find_files<cr>", desc = "Find files" },
        -- find
        { "<leader>fb", "<cmd>Telescope buffers sort_mru=true sort_lastused=true<cr>", desc = "Buffers" },
        { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
        { "<leader>fg", "<cmd>Telescope git_files<cr>", desc = "Git files" },
        { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent" },
        -- git
        { "<leader>gC", "<cmd>Telescope git_commits<cr>", desc = "Commits" },
        { "<leader>gs", "<cmd>Telescope git_status<cr>", desc = "Status" },
        { "<leader>gB", "<cmd>Telescope git_branches<cr>", desc = "Branches" },
        -- search
        { '<leader>s"', "<cmd>Telescope registers<cr>", desc = "Registers" },
        { "<leader>sa", "<cmd>Telescope autocommands<cr>", desc = "Autocommands" },
        { "<leader>sb", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Buffer" },
        { "<leader>sc", "<cmd>Telescope command_history<cr>", desc = "Command history" },
        { "<leader>sC", "<cmd>Telescope commands<cr>", desc = "Commands" },
        { "<leader>sd", "<cmd>Telescope diagnostics bufnr=0<cr>", desc = "Document diagnostics" },
        { "<leader>sD", "<cmd>Telescope diagnostics<cr>", desc = "Workspace diagnostics" },
        { "<leader>sg", "<cmd>Telescope live_grep<cr>", desc = "Grep" },
        -- { "<leader>sG", LazyVim.telescope("live_grep", { cwd = false }), desc = "Grep" },
        { "<leader>sh", "<cmd>Telescope help_tags<cr>", desc = "Help pages" },
        { "<leader>sH", "<cmd>Telescope highlights<cr>", desc = "Search highlight groups" },
        { "<leader>sk", "<cmd>Telescope keymaps<cr>", desc = "Keymaps" },
        { "<leader>sM", "<cmd>Telescope man_pages<cr>", desc = "Man pages" },
        -- { "<leader>sm", "<cmd>Telescope marks<cr>", desc = "Jump to mark" },
        { "<leader>so", "<cmd>Telescope vim_options<cr>", desc = "Options" },
        { "<leader>sR", "<cmd>Telescope resume<cr>", desc = "Resume" },
        { "<leader>sw", "<cmd>Telescope grep_string<cr>", desc = "Word" },
        { "<leader>sw", "<cmd>Telescope grep_string<cr>", mode = "v", desc = "Selection" },
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
      }
      return keys
    end,
    opts = function()
      local actions = require("telescope.actions")
      local Utils = require("bdsilver89.utils")

      local function open_with_trouble(...)
        -- return require("trouble.providers.telescope").open_with_trouble(...)
        return require("trouble.sources.telescope").open(...)
      end
      local function open_selected_with_trouble(...)
        return require("trouble.sources.telescope").open_selected(...)
        -- return require("trouble.providers.telescope").open_selected_with_trouble(...)
      end

      return {
        defaults = {
          prompt_prefix = Utils.ui.get_icon("telescope", "PromptPrefix"),
          selection_caret = Utils.ui.get_icon("telescope", "SelectionCaret"),
          sorting_strategy = "ascending",
          layout_strategy = "horizontal",
          layout_config = {
            horizontal = {
              prompt_position = "top",
              vertical = {
                mirror = false,
              },
            },
          },
          get_selection_window = function()
            local wins = vim.api.nvim_list_wins()
            table.insert(wins, 1, vim.api.nvim_get_current_win())
            for _, win in ipairs(wins) do
              local buf = vim.api.nvim_win_get_buf(win)
              if vim.bo[buf].buftype == "" then
                return win
              end
            end
            return 0
          end,
          mappings = {
            i = {
              ["<c-t>"] = open_with_trouble,
              ["<a-t>"] = open_selected_with_trouble,
              -- ["<a-i>"] = find_files_no_ignore,
              -- ["<a-h>"] = find_files_with_hidden,
              ["<C-Down>"] = actions.cycle_history_next,
              ["<C-Up>"] = actions.cycle_history_prev,
              ["<C-f>"] = actions.preview_scrolling_down,
              ["<C-b>"] = actions.preview_scrolling_up,
            },
            n = {
              ["q"] = actions.close,
            },
          },
        },
      }
    end,
    config = function(_, opts)
      require("telescope").setup(opts)

      pcall(require("telescope").load_extension, "fzf")
    end,
  },
}
