local add = MiniDeps.add

add("zbirenbaum/copilot.lua")
add("olimorris/codecompanion.nvim")

require("copilot").setup({
  panel = { enabled = false },
  suggestion = {
    auto_trigger = true,
    hide_during_completion = true,
    keymap = {
      accept = false,
      next = "<m-]>",
      prev = "<m-[>",
    },
    filetypes = {
      markdown = true,
      help = true,
    },
  },
})

require("codecompanion").setup({
  strategies = {
    chat = {
      adapter = { name = "copilot" },
      opts = {
        completion_provider = "blink",
      },
    },
    cmd = {
      adapter = { name = "copilot" },
    },
    inline = {
      adapter = { name = "copilot" },
    },
  },
})
