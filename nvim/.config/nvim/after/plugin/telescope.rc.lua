local status, telescope = pcall(require, "telescope")
if (not status) then return end
local actions = require('telescope.actions')
local builtin = require("telescope.builtin")

local function telescope_buffer_dir()
  return vim.fn.expand('%:p:h')
end

local fb_actions = require "telescope".extensions.file_browser.actions

telescope.setup {
  defaults = {
    prompt_prefix = " >",
    color_devicons = true,
    mappings = {
      n = {
        ["q"] = actions.close
      },
    },
  },
  extensions = {
    file_browser = {
      -- theme = "dropdown",
      hijack_netrw = true,
      mappings = {
        -- your custom insert mode mappings
        ["i"] = {
          ["<C-w>"] = function() vim.cmd('normal vbd') end,
        },
        ["n"] = {
          -- your custom normal mode mappings
          ["N"] = fb_actions.create,
          ["h"] = fb_actions.goto_parent_dir,
          ["/"] = function()
            vim.cmd('startinsert')
          end
        },
      },
    },
  },
}

telescope.load_extension("file_browser")
telescope.load_extension("git_worktree")
telescope.load_extension("harpoon")

vim.keymap.set('n', '<leader>ff',
  function()
    builtin.find_files({
      no_ignore = false,
      hidden = true
    })
  end)

vim.keymap.set('n', '<leader>fw', function()
  builtin.live_grep()
end)

vim.keymap.set('n', '<leader>\\\\', function()
  builtin.buffers()
end)

vim.keymap.set('n', '<leader>ht', function()
  builtin.help_tags()
end)

vim.keymap.set('n', '<leader>;;', function()
  builtin.resume()
end)

vim.keymap.set('n', '<leader>;e', function()
  builtin.diagnostics()
end)

vim.keymap.set("n", "<leader>fb", function()
  telescope.extensions.file_browser.file_browser({
    path = "%:p:h",
    cwd = telescope_buffer_dir(),
    respect_gitignore = false,
    hidden =  true,
    grouped = true,
    previewer = false,
    initial_mode = "insert",
    layout_config = { height = 40 }
  })
end)

vim.keymap.set("n", "<leader>gw", function()
  telescope.extensions.git_worktree.git_worktrees()
end, { noremap = true })

vim.keymap.set("n", "<leader>gm", function()
  telescope.extensions.git_worktree.create_git_worktree()
end, { noremap = true })

vim.keymap.set("n", "<leader>hp", function()
  telescope.extensions.harpoon.marks()
end, { noremap = true })
