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
    -- stylua: ignore
    keys = {
      { "<leader>bd", function() MiniBufremove.delete(0, false) end, "Delete buffer", },
      { "<leader><space>", "<cmd>Pick files<cr>", "Find files" },
      { "<leader>/", "<cmd>Pick grep_live<cr>", "Grep Live" },
      { "<leader>.", "<cmd>Pick grep<cr>", "Grep" },
      { "<leader>,", "<cmd>Pick buffers<cr>", "Buffers" },
    },
    opts = {
      bufremove = {},
      pick = {},
    },
    config = function(_, opts)
      for k, v in pairs(opts) do
        require("mini." .. k).setup(v)
      end
    end,
  },
}
