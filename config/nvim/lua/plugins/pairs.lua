return {
  {
    "echasnovski/mini.pairs",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      mappings = {
        ["`"] = { action = "closeopen", pair = "``", neigh_pattern = "[^\\`].", register = { cr = false } },
      },
    },
    keys = {
      {
        "<leader>up",
        function()
          vim.g.minipairs_disable = not vim.g.minipairs_disable
          if vim.g.minipairs_disable then
            vim.notify("Disabled auto pairs", vim.log.levels.WARN, { title = "Option" })
          else
            vim.notify("Enabled auto pairs", vim.log.levels.INFO, { title = "Option" })
          end
        end,
        desc = "Toggle Auto Pairs",
      },
    },
  },
}
