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

local fzf = vim.pack.get({ "telescope-fzf-native.nvim" })[1]
if fzf and vim.fn.filereadable(fzf.path .. "/build/libfzf.so") == 0 and vim.fn.executable("make") == 1 then
  vim.system({ "make" }, { cwd = fzf.path }):wait()
end

telescope.load_extension("fzf")
telescope.load_extension("ui-select")
telescope.load_extension("frecency")

vim.keymap.set("n", "<leader><space>", "<cmd>Telescope find_files<cr>")
vim.keymap.set("n", "<leader>/", "<cmd>Telescope live_grep<cr>")
vim.keymap.set("n", "<leader>:", "<cmd>Telescope command_history<cr>")
vim.keymap.set("n", "<leader>,", "<cmd>Telescope buffers sort_mru=true sort_lastused=true<cr>")

vim.keymap.set("n", "<leader>gc", "<cmd>Telescope git_commits<cr>")
vim.keymap.set("n", "<leader>gl", "<cmd>Telescope git_commits<cr>")
vim.keymap.set("n", "<leader>gs", "<cmd>Telescope git_status<cr>")
vim.keymap.set("n", "<leader>gS", "<cmd>Telescope git_stash<cr>")

vim.api.nvim_create_autocmd("FileType", {
  pattern = "TelescopePrompt",
  callback = function(ev) vim.bo[ev.buf].autocomplete = false end,
})
