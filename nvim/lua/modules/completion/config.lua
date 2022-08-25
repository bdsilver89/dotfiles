local config = {}

function config.nvim_lsp()
  require('modules.completion.lspconfig')
end

function config.lspsaga()
  local saga = require('lspsaga')
  saga.init_lsp_saga({
  --  symbol_in_winbar = {
  --    enable = true,
  --  },
  })
end

function config.nvim_cmp()
  local cmp = require('cmp')
  cmp.setup({
    preselect = cmp.PreselectMode.Item,
    window = {
      -- completion = cmp.config.window.bordered(),
      -- documentation = cmp.config.window.bordered(),
    },
    formatting = {
      fields = { 'abbr','kind', 'menu' },
    },
    -- You can set mappings if you want
    mapping = cmp.mapping.preset.insert({
      ['<C-e>'] = cmp.config.disable,
      ['<CR>'] = cmp.mapping.confirm({ select = true }),
    }),
    snippet = {
      expand = function(args)
        require('luasnip').lsp_expand(args.body)
      end,
    },
    sources = {
      { name = 'nvim_lsp' },
      { name = 'luasnip' },
      { name = 'path' },
      { name = 'buffer' },
    },
  })
end

function config.lua_snip()
  local ls = require('luasnip')
  ls.config.set_config({
    history = false,
    updateevents = 'TextChanged,TextChangedI',
  })
  require('luasnip.loaders.from_vscode').lazy_load()
  require('luasnip.loaders.from_vscode').lazy_load({
    paths = { './snippets/' },
  })
end

function config.auto_pairs()
  require('nvim-autopairs').setup({})
  local status, cmp = pcall(require, 'cmp')
  if not status then
    vim.cmd([[packadd nvim-cmp]])
  end
  cmp = require('cmp')
  local cmp_autopairs = require('nvim-autopairs.completion.cmp')
  cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())
end

function prettier()
  require('prettier').setup({
    bin = 'prettierd',
    filetypes = {
      'css',
      'javascript',
      'javascriptreact',
      'typescript',
      'typescriptreact',
      'json',
      'yaml',
      'scss',
      'less',
      'c',
      'cpp',
      'go',
      'rust',
      'python',
    }
  })
end

return config
