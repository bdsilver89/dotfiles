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

        -- terminal
        { "<leader>ft", function() Snacks.terminal() end, desc = "Terminal" },
        { "<c-/>", function() Snacks.terminal(nil) end, desc = "Teminal" },
        { "<c-_>", function() Snacks.terminal(nil) end, desc = "which_key_ignore" },
      },

    -- -- lazygit (if installed in env)
    -- if vim.fn.executable("lazygit") == 1 then
    --   vim.list_extend(keys, {
    --     { "<leader>gg", function() Snacks.lazygit() end, desc = "Lazygit"},
    --   })
    -- end
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
  },
}
