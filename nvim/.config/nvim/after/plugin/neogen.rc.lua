local status, neogen = pcall(require, 'neogen')
if (not status) then return end

local nnoremap = require('bdsilver89.keymap').nnoremap

neogen.setup({
  snippet_engine = 'luasnip',
  enabled = true,
  languages = {
    sh = {
      template = {
        annotation_convention = 'google_bash',
      },
    },
    c = {
      template = {
        annotation_convention = 'doxygen',
      },
    },
    cpp = {
      template = {
        annotation_convention = 'doxygen',
      },
    },
    go = {
      template = {
        annotation_convention = 'godoc',
      },
    },
    lua = {
      template = {
        annotation_convention = "ldoc",
      },
    },
    python = {
      template = {
        annotation_convention = "google_docstrings",
      },
    },
    rust = {
      template = {
        annotation_convention = "rustdoc",
      },
    },
    typescript = {
      template = {
        annotation_convention = "tsdoc",
      },
    },
  }
})

nnoremap('<leader>nf', function() neogen.generate({type = 'func'}) end, { silent = true })
nnoremap('<leader>nc', function() neogen.generate({type = 'class'}) end, { silent = true })
