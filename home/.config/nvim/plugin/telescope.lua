vim.api.nvim_create_autocmd("PackChanged", {
  group = vim.api.nvim_create_augroup("config_packchanged_telescope", { clear = true }),
  callback = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    if name == "telescope-fzf-native.nvim" and (kind == "install" or kind == "update") then
      if not ev.data.active then
        vim.cmd.packadd("telescope-fzf-native.nvim")
      end
      local result = vim.system({ "make" }, { cwd = ev.data.path, text = true }):wait()
      if result.code ~= 0 then
        error("Failed to build telescope-fzf-native.nvim: " .. (result.stderr or result.stdout or ""))
      end
    end
  end,
})

vim.pack.add({
  "https://github.com/nvim-lua/plenary.nvim",
  "https://github.com/nvim-telescope/telescope.nvim",
  "https://github.com/nvim-telescope/telescope-fzf-native.nvim",
  "https://github.com/nvim-telescope/telescope-ui-select.nvim",
  "https://github.com/nvim-telescope/telescope-frecency.nvim",
})

require("telescope").setup({
  defaults = {
    layout_strategy = "horizontal",
    layout_config = {
      horizontal = {
        prompt_position = "top",
        width = 0.8,
        height = 0.8,
        preview_width = 0.5,
        prompt_title = "",
        results_title = "",
        preview_title = "",
      },
    },
    path_display = { "filename_first" },
    sorting_strategy = "ascending",
    prompt_prefix = "",
    entry_prefix = "  ",
    prompt_title = false,
    results_title = false,
    preview_title = false,
  },
  extensions = {
    fzf = {
      fuzzy = true,
      override_generic_sorter = true,
      override_file_sorter = true,
      case_mode = "smart_case",
    },
    ["ui-select"] = {
      require("telescope.themes").get_dropdown({}),
    },
    frecency = {
      show_filter_column = false,
      hide_current_buffer = true,
      preceding = "opened",
      prompt_title = "",
      results_title = "",
      preview_title = "",
    },
  },
})

require("telescope").load_extension("fzf")
require("telescope").load_extension("ui-select")
require("telescope").load_extension("frecency")

-- vim.api.nvim_set_hl(0, "TelescopeBorder", { link = "FloatBorder" })
-- vim.api.nvim_set_hl(0, "TelescopePromptBorder", { link = "FloatBorder" })
-- vim.api.nvim_set_hl(0, "TelescopeResultsBorder", { link = "FloatBorder" })
-- vim.api.nvim_set_hl(0, "TelescopePreviewBorder", { link = "FloatBorder" })

vim.keymap.set("n", "<leader><space>", "<cmd>Telescope find_files<cr>")
vim.keymap.set("n", "<leader>/", "<cmd>Telescope live_grep<cr>")
vim.keymap.set("n", "<leader>,", "<cmd>Telescope buffers<cr>")
