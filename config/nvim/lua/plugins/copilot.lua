local copilot_enabled = false

-- stylua: ignore
if not copilot_enabled then return {} end

return {
  "zbirenbaum/copilot.lua",
  cmd = "Copilot",
  event = "InsertEnter",
  opts = {
    panel = { enabled = false },
    suggestion = {
      keymap = {
        accept = "<c-.>",
        accept_word = "<m-w>",
        accept_line = "<m-l>",
        next = "<m-]>",
        prev = "<m-[>",
        dismiss = "<c-/>",
      },
    },
  },
}
