-- Terminal Mappings
local function term_nav(dir)
  ---@param self snacks.terminal
  return function(self)
    return self:is_floating() and "<c-" .. dir .. ">" or vim.schedule(function()
      vim.cmd.wincmd(dir)
    end)
  end
end

return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  keys = function()
    -- stylua: ignore
    local keys = {
      -- bufdelete
      { "<leader>bd", function() Snacks.bufdelete() end, desc = "Delete Buffer" },
      { "<leader>bo", function() Snacks.bufdelete.other() end, desc = "Delete Other Buffers" },

      -- explorer
      { "<leader>fe", function() Snacks.explorer() end, desc = "Explorer (Snacks)" },
      { "<leader>e", "<leader>fe", remap = true ,desc = "Explorer (Snacks)" },

      -- picker
      { "<leader>,", function() Snacks.picker.buffers() end, desc = "Buffer" },
      { "<leader>/", function() Snacks.picker.grep() end, desc = "Grep" },
      { "<leader>:", function() Snacks.picker.command_history() end, desc = "Command History" },
      { "<leader><space>", function() Snacks.picker.files() end, desc = "Files" },

      { "<leader>ft", function() Snacks.terminal() end,  desc = "Terminal" },
      { "<c-/>", function() Snacks.terminal(nil) end, desc = "Terminal" },
      { "<c-_>", function() Snacks.terminal(nil) end, desc = "which_key_ignore" },
    }

    if vim.fn.executable("lazygit") == 1 then
      -- stylua: ignore
      vim.list_extend(keys, {
        { "<leader>gg", function() Snacks.lazygit() end, desc = "Lazygit" },
        { "<leader>gf", function() Snacks.picker.git_log_file() end, desc = "Git File History" },
        { "<leader>gl", function() Snacks.picker.git_log() end, desc = "Git Log" },
      })
    end

    return keys
  end,
  opts = function()
    local opts = {
      bigfile = { enabled = true },
      dashboard = {},
      input = { enabled = true },
      indent = {
        enabled = true,
        animate = {
          enabled = false,
        },
      },
      terminal = {
        win = {
          keys = {
            nav_h = { "<c-h>", term_nav("h"), desc = "Go to Left Window", expr = true, mode = "t" },
            nav_j = { "<c-j>", term_nav("j"), desc = "Go to Lower Window", expr = true, mode = "t" },
            nav_k = { "<c-k>", term_nav("k"), desc = "Go to Upper Window", expr = true, mode = "t" },
            nav_l = { "<c-l>", term_nav("l"), desc = "Go to Right Window", expr = true, mode = "t" },
          },
        },
      },
      quickfile = { enabled = true },
      words = { enabled = true },
    }

    Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
    Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
    Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
    Snacks.toggle.diagnostics():map("<leader>ud")
    Snacks.toggle.line_number():map("<leader>ul")
    Snacks.toggle
      .option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2, name = "Conceal Level" })
      :map("<leader>uC")
    Snacks.toggle
      .option("showtabline", { off = 0, on = vim.o.showtabline > 0 and vim.o.showtabline or 2, name = "Tabline" })
      :map("<leader>uA")
    Snacks.toggle.treesitter():map("<leader>uT")
    Snacks.toggle.option("background", { off = "light", on = "dark", name = "Dark Background" }):map("<leader>ub")
    Snacks.toggle.dim():map("<leader>uD")
    Snacks.toggle.animate():map("<leader>ua")
    Snacks.toggle.indent():map("<leader>ug")
    Snacks.toggle.scroll():map("<leader>uS")

    Snacks.toggle.zoom():map("<leader>wm"):map("<leader>uZ")
    Snacks.toggle.zen():map("<leader>uz")

    if vim.lsp.inlay_hint then
      Snacks.toggle.inlay_hints():map("<leader>uh")
    end
    -- Snacks.toggle.codelens():map("<leader>uc")

    return opts
  end,
}
