local status, telescope = pcall(require, "telescope")
if (not status) then return end

local actions = require('telescope.actions')
local builtin = require("telescope.builtin")
local Remap = require('bdsilver89.keymap')
local nnoremap = Remap.nnoremap

telescope.setup({
  defaults = {
    file_sorter = require('telescope.sorters').get_fzy_sorter,
    prompt_prefix = " >",
    color_devicons = true,
    file_previewer = require('telescope.previewers').vim_buffer_cat.new,
    grep_previewer = require('telescope.previewers').vim_buffer_vimgrep.new,
    qflist_previewer = require('telescope.previewers').vim_buffer_qflist.new,
    mappings = {
      n = {
        ["q"] = actions.close
      },
      i = {
        ["<C-x>"] = false,
        ["<C-q>"] = actions.send_to_qflist,
      }
    },
  },
  extensions = {
    file_browser = {
      -- theme = "dropdown",
      hijack_netrw = true,
      mappings = {
        ["i"] = {
          ["<C-w>"] = function() vim.cmd('normal vbd') end,
        },
      },
    },
  },
})

telescope.load_extension("file_browser")
telescope.load_extension("git_worktree")

nnoremap('<C-p>', ':Telescope')

nnoremap('<leader>fw', function() builtin.grep_string() end)

nnoremap('<leader>fg', function() builtin.live_grep() end)

nnoremap('<leader>ff', function() builtin.find_files() end)

nnoremap('<leader>bb', function() builtin.buffers() end)

nnoremap('<leader>ht', function() builtin.help_tags() end)

nnoremap('<leader>fb', function()
  telescope.extensions.file_browser.file_browser({
    path = "%:p:h",
    cwd = vim.fn.expand('%:p:h'),
    respect_gitignore = false,
    hidden = true,
    grouped = true,
    -- previewer = false,
    initial_mode = "insert",
    -- layout_config = { height = 40 }
  })
end)

nnoremap('<leader>vrc', function()
  builtin.find_files({
    prompt_title = '< Dotfiles >',
    cwd = vim.env.DOTFILES,
    hidden = true,
  })
end)

nnoremap('<leader>gw', function()
  telescope.extensions.git_worktree.git_worktrees()
end)

nnoremap('<leader>gm', function()
  telescope.extensions.git_worktree.create_git_worktree()
end)

