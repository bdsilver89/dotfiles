local config = {}

function config.telescope()
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
end

function config.nvim_treesitter()
  vim.api.nvim_command('set foldmethod=expr')
  vim.api.nvim_command('set foldexpr=nvim_treesitter#foldexpr()')
  require('nvim-treesitter.configs').setup({
    ensure_installed = 'all',
    ignore_install = { 'phpdoc', 'vala', 'tiger', 'slint', 'eex' },
    highlight = {
      enable = true,
    },
    textobjects = {
      select = {
        enable = true,
        keymaps = {
          ['af'] = '@function.outer',
          ['if'] = '@function.inner',
          ['ac'] = '@class.outer',
          ['ic'] = '@class.inner',
        },
      },
    },
  })
end

function config.mcc_nvim()
  require('mcc').setup({
    go = { ';', ':=', ';' },
    rust = { '88', '::', '88' },
    c = { '-', '->', '-' },
    cpp = { '-', '->', '--' },
  })
end

function config.formatter()
  require('formatter').setup({
    logging = true,
    log_level = vim.log.levels.WARN,
    filetype = {
      cmake = {
        require("formatter.filetypes.cmake").cmakeformat
      },
      cpp = {
        require("formatter.filetypes.cpp").clangformat
      },
      c = {
        require("formatter.filetypes.c").clangformat
      },
      go = {
        require("formatter.filetypes.go").gofmt
      },
      markdown = {
        require("formatter.filetypes.markdown").prettier
      },
      python = {
        require("formatter.filetypes.python").autopep8
      },
      rust = {
        require("formatter.filetypes.rust").rustfmt
      },
      sh = {
        require("formatter.filetypes.sh").shfmt
      },
      typescript = {
        require("formatter.filetypes.typescript").eslint_d
      },
      ["*"] = {
        require("formatter.filetypes.any").remove_trailing_whitespace
      }
    }
  })
end

function config.hop()
  require('hop').setup({
    keys = 'etovxqpdygfblzhckisuran',
  })
end

return config
