local copilot_enabled = false

-- stylua: ignore
if not copilot_enabled then return {} end

return {
  "zbirenbaum/copilot.lua",
  event = "InsertEnter",
  opts = {
    panel = { enabled = false },
    suggestion = {
      keymap = {
        accept = "<C-.>",
        accept_word = "<M-w>",
        accept_line = "<M-l>",
        next = "<M-]>",
        prev = "<M-[>",
        dismiss = "<C-/>",
      },
    },
  },
}
