local config = {}

function config.telescope()
  require('modules.editor.config.telescope-rc')
end

function config.nvim_treesitter()
  require('modules.editor.config.treesitter-rc')
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
  require('modules.editor.config.formatter-rc')
end

function config.hop()
  require('hop').setup({
    keys = 'etovxqpdygfblzhckisuran',
  })
end

function config.nvim_comment()
  require('nvim_comment').setup({
    marker_padding = true,
    comment_empty = true,
    comment_empty_trim_whitespace = true,
    create_mappings = true,
    line_mapping = 'gcc',
    operator_mapping = 'gc',
    comment_chunk_text_object = 'ic',
    hook = nil,
  })
end

function config.nvim_dap()
  require('modules.editor.config.dap-rc')
end

function config.nvim_dap_ui()
  require('modules.editor.config.dap-ui-rc')
end

function config.neotest()
  -- if not packer_plugins['plenary.nvim'].loaded then
  --   vim.cmd([[packadd plenary.nvim]])
  -- end
  require('neotest').setup({
    adapters = {
      -- require('neotest-plenary'),
    },
  })
end

return config
