-- mini.extra
require("mini.extra").setup()

-- mini.bufremove
vim.keymap.set("n", "<leader>bd", function()
  require("mini.bufremove").delete(0)
end, { desc = "Buffer remove" })
vim.keymap.set("n", "<leader>bD", function()
  require("mini.bufremove").delete(0, true)
end, { desc = "Buffer remove (force)" })

-- mini.icons
local icons = require("mini.icons")
icons.setup()
icons.mock_nvim_web_devicons()

-- mini.notify
local notify = require("mini.notify")
notify.setup()
vim.notify = notify.make_notify()

-- mini.hipatterns
local hipatterns = require("mini.hipatterns")
hipatterns.setup({
  highlighters = {
    fixme = { pattern = "%f[%w]()FIXME()%f[%W]", group = "MiniHipatternsFixme" },
    hack = { pattern = "%f[%w]()HACK()%f[%W]", group = "MiniHipatternsHack" },
    todo = { pattern = "%f[%w]()TODO()%f[%W]", group = "MiniHipatternsTodo" },
    note = { pattern = "%f[%w]()NOTE()%f[%W]", group = "MiniHipatternsNote" },
    hex_color = hipatterns.gen_highlighter.hex_color(),
  },
})

-- mini.clue
local clue = require("mini.clue")
clue.setup({
  triggers = {
    { mode = "n", keys = "<leader>" },
    { mode = "x", keys = "<leader>" },

    { mode = "i", keys = "<c-x>" },

    { mode = "n", keys = "g" },
    { mode = "x", keys = "g" },

    { mode = "n", keys = "s" },

    { mode = "n", keys = "<c-w>" },

    { mode = "n", keys = "z" },
    { mode = "x", keys = "z" },
  },
  clues = {
    clue.gen_clues.g(),
    clue.gen_clues.builtin_completion(),
    clue.gen_clues.windows(),
    clue.gen_clues.z(),
  },
})

-- mini.pairs
require("mini.pairs").setup()
vim.keymap.set("n", "<leader>up", function()
  local state = vim.g.minipairs_disable
  vim.g.minipairs_disable = not state
  if vim.g.minipairs_disable then
    vim.notify("***Disabled autopairs***", vim.log.levels.WARN)
  else
    vim.notify("***Enabled autopairs***", vim.log.levels.INFO)
  end
end, { desc = "Toggle autopairs" })

-- mini.ai
local ai = require("mini.ai")
ai.setup({
  custom_textobjects = {
    o = ai.gen_spec.treesitter({
      a = { "@block.outer", "@conditional.outer", "@loop.outer" },
      i = { "@block.inner", "@conditional.inner", "@loop.inner" },
    }),
    f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),
    c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }),
    u = ai.gen_spec.function_call(),
    U = ai.gen_spec.function_call({ name_pattern = "[%w_]" }),
  },
})

-- mini.surround
require("mini.surround").setup()

-- mini.diff
require("mini.diff").setup()

-- mini.git
require("mini.git").setup()

-- mini.statusline
local statusline = require("mini.statusline")
statusline.setup()
statusline.section_location = function()
  return "%2l:%-2v"
end

-- mini.tabline
require("mini.tabline").setup()

-- mini.indentscope
local indentscope = require("mini.indentscope")
indentscope.setup({
  draw = {
    animatiton = indentscope.gen_animation.none(),
  },
})

-- mini.files
require("mini.files").setup()
vim.keymap.set("n", "<leader>e", MiniFiles.open)

-- mini.pick
require("mini.pick").setup()
vim.ui.select = MiniPick.ui_select

vim.keymap.set("n", "<leader><space>", "<cmd>Pick files<cr>", { desc = "Pick files" })
vim.keymap.set("n", "<leader>,", "<cmd>Pick buffers<cr>", { desc = "Pick buffers" })
-- vim.keymap.set("n", "<leader>/", "<cmd>Pick grep_live<cr>", { desc = "Pick live grep" })
