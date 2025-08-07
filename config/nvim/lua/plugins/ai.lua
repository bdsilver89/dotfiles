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
      adapter = { name = "copilot", model = "claude-sonnet-4" },
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

vim.cmd([[cab cc CodeCompanion]])

local progress = require("fidget.progress")
local handle = nil

local group = vim.api.nvim_create_augroup("CodeCompanionFidgetHooks", {})
vim.api.nvim_create_autocmd("User", {
  pattern = "CodeCompanionRequest",
  group = group,
  callback = function(ev)
    if ev.match == "CodeCompanionRequestStart" then
      local adapter_name = "TODO"
      local model_name = "TODO"
      handle = progress.handle.create({
        title = " Requesting assistance",
        lsp_client = {
          name = string.format("CodeCompanion (%s - %s)", adapter_name, model_name),
        },
      })
    elseif ev.match == "CodeCompanionRequestFinished" then
      if handle then
        handle:finish()
      end
    end
  end,
})
