local copilot_enabled = false

-- stylua: ignore
if not copilot_enabled then return {} end 

return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    build = ":Copilot auth",
    event = "BufReadPost",
    opts = {
      suggestion = {
        enabled = not vim.g.ai_cmp,
        auto_trigger = true,
        hide_during_completion = vim.g.ai_cmp,
        keymap = {
          accept = false, -- handled by nvim-cmp / blink.cmp
          next = "<M-]>",
          prev = "<M-[>",
        },
      },
      panel = { enabled = false },
      filetypes = {
        markdown = true,
        help = true,
      },
    },
  },

  {
    "zbirenbaum/copilot.lua",
    opts = function()
      require("cmp_utils").actions.ai_accept = function()
        if require("copilot.suggestion").is_visible() then
          -- create undo point
          if vim.api.nvim_get_mode().mode == "i" then
            local undo = vim.api.nvim_replace_termcodes("<c-G>u", true, true, true)
            vim.api.nvim_feedkeys(undo, "n", false)
          end

          require("copilot.suggestion").accept()
          return true
        end
      end
    end,
  },

  {
    "saghen/blink.cmp",
    optional = true,
    dependencies = { "giuxtaposition/blink-cmp-copilot" },
    opts = {
      sources = {
        default = { "copilot" },
        providers = {
          copilot = {
            name = "copilot",
            module = "blink-cmp-copilot",
            kind = "Copilot",
            score_offset = 100,
            async = true,
          },
        },
      },
    },
  },
}
