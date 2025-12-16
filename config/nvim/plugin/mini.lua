require("mini.icons").setup()

require("mini.misc").setup()

local statusline = require("mini.statusline")
statusline.setup()
statusline.section_location = function()
  return "%2l:%-2v"
end

require("mini.tabline").setup()

require("mini.extra").setup()

local clue = require("mini.clue")
clue.setup({
  triggers = {
    -- Leader triggers
    { mode = "n", keys = "<Leader>" },
    { mode = "x", keys = "<Leader>" },

    -- Built-in completion
    { mode = "i", keys = "<C-x>" },

    -- `g` key
    { mode = "n", keys = "g" },
    { mode = "x", keys = "g" },

    -- Marks
    { mode = "n", keys = "'" },
    { mode = "n", keys = "`" },
    { mode = "x", keys = "'" },
    { mode = "x", keys = "`" },

    -- Registers
    { mode = "n", keys = '"' },
    { mode = "x", keys = '"' },
    { mode = "i", keys = "<C-r>" },
    { mode = "c", keys = "<C-r>" },

    -- Window commands
    { mode = "n", keys = "<C-w>" },

    -- `z` key
    { mode = "n", keys = "z" },
    { mode = "x", keys = "z" },
  },

  clues = {
    clue.gen_clues.builtin_completion(),
    clue.gen_clues.g(),
    clue.gen_clues.marks(),
    clue.gen_clues.registers(),
    clue.gen_clues.windows(),
    clue.gen_clues.z(),
    { mode = "n", keys = "<leader>b", desc = "+buffer" },
    { mode = "n", keys = "<leader>c", desc = "+code" },
    { mode = "n", keys = "<leader>g", desc = "+git" },
    { mode = "n", keys = "<leader>s", desc = "+search" },
    { mode = "n", keys = "<leader>t", desc = "+terminal" },
  },
})

local process_items_opts = { kind_priority = { Text = -1, Snippet = 99 } }
local process_items = function(items, base)
  return MiniCompletion.default_process_items(items, base, process_items_opts)
end
require("mini.completion").setup({
  lsp_completion = {
    source_func = "omnifunc",
    auto_setup = false,
    process_items = process_items,
  },
})

require("mini.diff").setup({
  view = {
    style = "sign",
    signs = { add = "▎", change = "▎", delete = "" },
  },
})

-- require("mini.git").setup()

local hipatterns = require("mini.hipatterns")
local hi_words = MiniExtra.gen_highlighter.words
hipatterns.setup({
  highlighters = {
    fixme = hi_words({ "FIXME", "Fixme", "fixme" }, "MiniHipatternsFixme"),
    hack = hi_words({ "HACK", "Hack", "hack" }, "MiniHipatternsHack"),
    todo = hi_words({ "TODO", "Todo", "todo" }, "MiniHipatternsTodo"),
    note = hi_words({ "NOTE", "Note", "note" }, "MiniHipatternsNote"),
    hex_color = hipatterns.gen_highlighter.hex_color(),
  },
})

require("mini.indentscope").setup()

require("mini.pairs").setup({ modes = { command = true } })

require("mini.pick").setup()

local snippets = require("mini.snippets")
snippets.setup({
  snippets = {
    snippets.gen_loader.from_lang(),
  },
})

require("mini.surround").setup()

