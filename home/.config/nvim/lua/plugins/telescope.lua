vim.api.nvim_create_autocmd("PackChanged", {
  callback = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    if name == "telescope-fzf-native.nvim" and (kind == "install" or kind == "update") then
      if vim.fn.executable("make") == 1 then
        vim.system({ "make" }, { cwd = ev.data.path }):wait()
      end
    end
  end,
})

local telescope = require("telescope")
local builtin = require("telescope.builtin")
local actions = require("telescope.actions")

telescope.setup({
  defaults = {
    path_display = { "truncate", "filename_first" },
    mappings = {
      i = {
        ["<c-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
      },
      n = {
        ["<c-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
      },
    },
  },
  extensions = {
    fzf = {
      fuzzy = true,
      override_generic_sorter = true,
      override_file_sorter = true,
      case_mode = "smart_case",
    },
    frecency = {
      db_safe_mode = false,
      db_validate_threshold = 0,
      show_filter_column = false,
    },
    ["ui-select"] = require("telescope.themes").get_dropdown({}),
  },
})

telescope.load_extension("fzf")
telescope.load_extension("ui-select")
telescope.load_extension("frecency")

vim.keymap.set("n", "<leader><space>", function()
  -- builtin.find_files({ cwd = vim.fn.getcwd() })
  telescope.extensions.frecency.frecency({ cwd = vim.fn.getcwd(), workspace = "CWD", hidden = true })
end)
vim.keymap.set("n", "<leader>/", function()
  builtin.live_grep({ cwd = vim.fn.getcwd() })
end)
vim.keymap.set("n", "<leader>:", function()
  builtin.command_history()
end)
vim.keymap.set("n", "<leader>,", function()
  builtin.buffers()
end)

vim.api.nvim_create_autocmd("FileType", {
  pattern = "TelescopePrompt",
  callback = function(ev) vim.bo[ev.buf].autocomplete = false end,
})
