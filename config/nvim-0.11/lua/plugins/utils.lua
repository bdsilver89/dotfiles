-- local function term_nav(dir)
--   ---@param self snacks.terminal
--   return function(self)
--     return self:is_floating() and "<c-" .. dir .. ">" or vim.schedule(function()
--       vim.cmd.wincmd(dir)
--     end)
--   end
-- end

return {
  { "folke/lazy.nvim", version = "*" },

  -- general lua utilities
  "nvim-lua/plenary.nvim",

  -- schema utilities for json and yaml lsp
  {
    "b0o/SchemaStore.nvim",
    lazy = true,
    version = false,
  },

  {
    "echasnovski/mini.nvim",
    event = "VeryLazy",
    keys = {
      {
        "<leader>bd",
        function()
          MiniBufremove.delete(0, false)
        end,
        "Delete buffer",
      },
    },
    opts = {
      bufremove = {},
    },
    config = function(_, opts)
      for k, v in pairs(opts) do
        require("mini." .. k).setup(v)
      end
    end,
  },
}
