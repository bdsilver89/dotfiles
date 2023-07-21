return {
  {
    "bdsilver89/perforce.nvim",
    enabled = vim.fn.executable("p4") == 1,
    event = { "BufReadPost", "BufNewFile" },
    branch = "develop",
    -- opts = {
    --   on_attach = function(buffer)
    --     local p4 = package.loaded.perforce
    --
    --     local function map(mode, l, r, desc)
    --       vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
    --     end
    --
    --     -- stylua: ignore start
    --     map("n", "]p", p4.next_hunk, "Next hunk")
    --     map("n", "[p", p4.prev_hunk, "Prev hunk")
    --     map("n", "<leader>php", p4.preview_hunk, "Preview hunk")
    --     map("n", "<leader>phd", p4.diff, "Diff this")
    --   end,
    -- }
    config = true,
  }
}
