if not packer_plugins['plenary.nvim'].loaded then
  vim.cmd([[packadd plenary.nvim]])
  vim.cmd([[packadd popup.nvim]])
end
vim.cmd([[packadd sqlite.lua]])
vim.cmd([[packadd telescope-fzy-native.nvim]])
vim.cmd([[packadd telescope-project.nvim]])
vim.cmd([[packadd telescope-frecency.nvim]])
vim.cmd([[packadd telescope-file-browser.nvim]])

require('telescope').setup({
  defaults = {
    prompt_prefix = '🔭 ',
    selection_caret = ' ',
    layout_config = {
      horizontal = { prompt_position = 'top', results_width = 0.6 },
      vertical = { mirror = false },
    },
    sorting_strategy = 'ascending',
    file_previewer = require('telescope.previewers').vim_buffer_cat.new,
    grep_previewer = require('telescope.previewers').vim_buffer_vimgrep.new,
    qflist_previewer = require('telescope.previewers').vim_buffer_qflist.new,
    mappings = {
      n = {
        ["q"] = require('telescope.actions').close,
      },
    },
  },
  extensions = {
    fzy_native = {
      override_generic_sorter = false,
      override_file_sorter = true,
    },
    frecency = {
      show_scores = true,
      show_unindexed = true,
      ignore_patterns = { '*.git/*', '/tmp/*' },
    },
    file_brower = {
      theme = "dropdown",
      hijack_netrw = true,
    },
    project = {
      hidden_files = true,
      theme = "dropdown"
    }
  },
})
require('telescope').load_extension('fzy_native')
require('telescope').load_extension('project')
require('telescope').load_extension('frecency')
require('telescope').load_extension('file_browser')
require('telescope').load_extension('dotfiles')
require('telescope').load_extension('gosource')
