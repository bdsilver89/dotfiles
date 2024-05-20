return {
  {
    "stevearc/oil.nvim",
    cmd = "Oil",
    keys = {
      { "<leader>o", function() require("oil").open() end, desc = "File explorer (oil)" },
    },
    opts = {},
    config = function(_, opts)
      require("oil").setup(opts)

      -- vim.api.nvim_create_autocmd("User", {
      --   desc = "Close buffers when files are deleted in oil",
      --   pattern = "OilActionsPost",
      --   callback = function(args)
      --     if args.data.err then
      --       return
      --     end
      --     for _, action in ipairs(args.data.actions) do
      --       if action.type == "delete" then
      --         local _, path = require("oil.uilt").parse_url(action.url)
      --         local bufnr = vim.fn.bufnr(path)
      --         if bufnr ~= -1 then
      --
      --         end
      --       end
      --     end
      --   end,
      -- })
    end,
  },
}
