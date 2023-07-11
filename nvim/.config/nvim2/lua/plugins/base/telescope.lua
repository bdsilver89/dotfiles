local utils = require("config.utils")

local function open_telescope(builtin, opts)
  local params = { builtin = builtin, opts = opts }
  return function()
    builtin = params.builtin
    opts = params.opts
    opts = vim.tbl_deep_extend("force", { cwd = utils.get_root() }, opts or {})
    if builtin == "files" then
      if vim.loop.fs_stat((opts.cwd or vim.loop.cwd()) .. "/.git") then
        opts.show_untracked = true
        builtin = "git_files"
      else
        builtin = "find_files"
      end
    end
    require("telescope.builtin")[builtin](opts)
  end
end

return {
  {
    "nvim-telescope/telescope.nvim",
    commit = vim.fn.has("nvim-0.9.0") == 0 and "057ee0f8783" or nil,
    cmd = "Telescope",
    dependencies = {
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
      },
    },
    keys = {
      { "<leader>,", "<cmd>Telescope buffers show_all_buffers=true<cr>", desc = "Switch buffer" },
      { "<leader>/", open_telescope("live_grep"), desc = "Grep (root dir)" },
      { "<leader>:", "<cmd>Telescope command_history<cr>", desc = "Command history" },
      { "<leader><space>", open_telescope("files"), desc = "Find files" },
      -- find
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Find buffers" },
      { "<leader>ff", open_telescope("files"), desc = "Find files (root dir)" },
      { "<leader>fF", open_telescope("files", { cwd = false }), desc = "Find files (cwd)" },
      { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Find recent files" },
      { "<leader>fR", open_telescope("oldfiles", { cwd = vim.loop.cwd() }), desc = "Find recent files (cwd)" },
      -- git
      { "<leader>gc", "<cmd>Telescope git_commits<cr>", desc = "Git commits" },
      { "<leader>gs", "<cmd>Telescope git_status<cr>", desc = "Git status" },
      -- search
      { "<leader>sa", "<cmd>Telescope autocommands<cr>", desc = "Search autocommands" },
      { "<leader>sb", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Search in buffer" },
      { "<leader>sc", "<cmd>Telescope command_history<cr>", desc = "Search command history" },
      { "<leader>sd", "<cmd>Telescope diagnostics bufnr=0<cr>", desc = "Search document diagnostics" },
      { "<leader>sD", "<cmd>Telescope diagnostics<cr>", desc = "Search workspace diagnostics" },
      { "<leader>sg", open_telescope("live_grep"), desc = "Grep" },
      { "<leader>sG", open_telescope("live_grep", { cwd = false }), desc = "Grep (cwd)" },
      { "<leader>sh", "<cmd>Telescope help_tags<cr>", desc = "Search help pages" },
      { "<leader>sH", "<cmd>Telescope highlight<cr>", desc = "Search highlight groups" },
      { "<leader>sk", "<cmd>Telescope keymaps<cr>", desc = "Search keymaps" },
      { "<leader>sM", "<cmd>Telescope man_pages<cr>", desc = "Search man pages" },
      { "<leader>sn", "<cmd>Telescope notify<cr>", desc = "Search notify messages" },
      { "<leader>sw", open_telescope("grep_string"), desc = "Word (root dir)" },
      { "<leader>sW", open_telescope("grep_string", { cwd = false }), desc = "Word (cwd)" },
      { "<leader>uC", "<cmd>Telescope colorscheme<cr>", desc = "Set colorscheme" },
      {
        "<leader>ss",
        open_telescope("lsp_document_symbols", {
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
        desc = "Goto Symbol",
      },
      {
        "<leader>sS",
        open_telescope("lsp_dynamic_workspace_symbols", {
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
        desc = "Goto Symbol (Workspace)",
      },
    },
    opts = function()
      local actions = require("telescope.actions")
      return {
        defaults = {
        },
        -- layout_strategy = "horizontal",
        -- layout_config = {},
        -- sorting_strategy
        -- winblend
        -- mappings
      }
    end,
    config = function(_, opts)
      local telescope = require("telescope")
      telescope.setup(opts)

      telescope.load_extension("notify")
      telescope.load_extension("fzf")
    end,
  },
}
