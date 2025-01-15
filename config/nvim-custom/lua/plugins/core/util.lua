local function term_nav(dir)
  ---@param self snacks.terminal
  return function(self)
    return self:is_floating() and "<c-" .. dir .. ">" or vim.schedule(function()
      vim.cmd.wincmd(dir)
    end)
  end
end

return {
  "nvim-lua/plenary.nvim",

  {
    "snacks.nvim",
    -- stylua: ignore
    keys = {
      -- buf
      { "<leader>bd", function() Snacks.bufdelete() end, desc = "Delete Buffer" },
      { "<leader>bo", function() Snacks.bufdelete.other() end, desc = "Delete Other Buffers" },
      { "<leader>bo", function() Snacks.bufdelete.other() end, desc = "Delete Other Buffers" },

      -- git
      { "<leader>gb", function() Snacks.git.blame_line() end, desc = "Git Blame Line" },
      { "<leader>gB", function() Snacks.gitbrowse() end, desc = "Git Browse (open)" },
      {
      "<leader>gg", function()
        if vim.fn.executable("lazygit") == 1 then
          Snacks.lazygit()
        else
          vim.notify("No lazygit executable found", vim.log.levels.WARN, {title = "Lazygit" })
        end
        end,
          desc = "Lazygit"
      },

      -- terminal
      { "<leader>ft", function() Snacks.terminal() end, desc = "Terminal" },
      { "<c-/>", function() Snacks.terminal(nil) end, desc = "Teminal" },
      { "<c-_>", function() Snacks.terminal(nil) end, desc = "which_key_ignore" },
    },
    opts = {
      bigfile = { enabled = true },
      quickfile = { enabled = true },
      terminal = {
        win = {
          keys = {
            nav_h = { "<C-h>", term_nav("h"), desc = "Go to Left Window", expr = true, mode = "t" },
            nav_j = { "<C-j>", term_nav("j"), desc = "Go to Lower Window", expr = true, mode = "t" },
            nav_k = { "<C-k>", term_nav("k"), desc = "Go to Upper Window", expr = true, mode = "t" },
            nav_l = { "<C-l>", term_nav("l"), desc = "Go to Right Window", expr = true, mode = "t" },
          },
        },
      },
    },
    init = function()
      vim.api.nvim_create_autocmd("User", {
        pattern = "VeryLazy",
        callback = function()
          -- stylua: ignore start
          Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
          Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
          Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
          Snacks.toggle.diagnostics():map("<leader>ud")
          Snacks.toggle.line_number():map("<leader>ul")
          Snacks.toggle.treesitter():map("<leader>uT")
          Snacks.toggle.option("background", { off = "light", right = "dark", name = "Dark Background" }):map("<leader>ub")
          if vim.lsp.inlay_hint then
            Snacks.toggle.inlay_hints():map("<leader>uh")
          end

          Snacks.toggle({
            name = "Autoformat (Global)",
            get = function()
              return vim.g.autoformat == nil or vim.g.autoformat
            end,
            set = function(state)
              vim.g.autoformat = state
              vim.b.autoformat = nil
            end,
          }):map("<leader>uf")

          Snacks.toggle({
            name = "Autoformat (Buffer)",
            get = function()
              local buf = vim.api.nvim_get_current_buf()
              local gaf = vim.g.autoformat
              local baf = vim.b[buf].autoformat

              if baf ~= nil then
                return baf
              end
              return gaf == nil or gaf
            end,
            set = function(state)
              vim.b.autoformat = state
            end,
          }):map("<leader>uF")

          -- stylua: ignore end
        end,
      })
    end,
  },
}
