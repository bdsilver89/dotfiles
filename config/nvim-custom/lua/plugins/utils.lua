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

  "nvim-lua/plenary.nvim",

  -- {
  --   "folke/snacks.nvim",
  --   priority = 1000,
  --   lazy = false,
  --   -- stylua: ignore
  --   keys = {
  --     -- buf
  --
  --     -- terminal
  --     { "<leader>ft", function() Snacks.terminal() end, desc = "Terminal" },
  --     { "<c-/>", function() Snacks.terminal(nil) end, desc = "Terminal" },
  --     { "<c-_", function() Snacks.terminal(nil) end, desc = "which_key_ignore" },
  --   },
  --   opts = {
  --     bigfile = { enabled = true },
  --     quickfile = { enabled = true },
  --     terminal = {
  --       win = {
  --         keys = {
  --           nav_h = { "<c-h>", term_nav("h"), desc = "Go to Left Window", expr = true, mode = "t" },
  --           nav_j = { "<c-j>", term_nav("j"), desc = "Go to Lower Window", expr = true, mode = "t" },
  --           nav_k = { "<c-k>", term_nav("k"), desc = "Go to Upper Window", expr = true, mode = "t" },
  --           nav_l = { "<c-l>", term_nav("l"), desc = "Go to Right Window", expr = true, mode = "t" },
  --         },
  --       },
  --     },
  --   },
  --   init = function()
  --     vim.api.nvim_create_autocmd("User", {
  --       pattern = "VeryLazy",
  --       callback = function()
  --         -- stylua: ignore start
  --         Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
  --         Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
  --         Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
  --         Snacks.toggle.option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2, name = "Conceal Level" }):map("<leader>uc")
  --         Snacks.toggle.diagnostics():map("<leader>ud")
  --         Snacks.toggle.line_number():map("<leader>ul")
  --         Snacks.toggle.treesitter():map("<leader>uT")
  --         Snacks.toggle.option("background", { off = "light", on = "dark", name = "Dark Background" }):map("<leader>ub")
  --         if vim.lsp.inlay_hints then
  --           Snacks.toggle.inlay_hints():map("<leader>uh")
  --         end
  --         -- stylua: ignore end
  --       end,
  --     })
  --   end,
  -- },
}
