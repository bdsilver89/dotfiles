vim.pack.add({
  "https://github.com/nvim-mini/mini.nvim",
})

require("mini.icons").setup({})
MiniIcons.mock_nvim_web_devicons()

vim.schedule(function()
  MiniIcons.tweak_lsp_kind()

  require("mini.pairs").setup({})
  require("mini.surround").setup({})

  -- local indentscope = require("mini.indentscope")
  -- indentscope.setup({
  --   draw = {
  --     animation = indentscope.gen_animation.none()
  --   }
  -- })

  local hipatterns = require("mini.hipatterns")
  hipatterns.setup({
    highlighters = {
      fixme = { pattern = '%f[%w]()FIXME()%f[%W]', group = 'MiniHipatternsFixme' },
      hack  = { pattern = '%f[%w]()HACK()%f[%W]',  group = 'MiniHipatternsHack'  },
      todo  = { pattern = '%f[%w]()TODO()%f[%W]',  group = 'MiniHipatternsTodo'  },
      note  = { pattern = '%f[%w]()NOTE()%f[%W]',  group = 'MiniHipatternsNote'  },
    }
  })
end)
